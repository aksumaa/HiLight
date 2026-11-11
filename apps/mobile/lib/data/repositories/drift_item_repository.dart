import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/library_item.dart';
import 'item_repository.dart';

class DriftItemRepository implements ItemRepository {
  DriftItemRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<LibraryItem>> watchAll() {
    final query = _database.select(_database.items)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);
    return query.watch().map((rows) => rows.map(libraryItemFromRow).toList());
  }

  @override
  Future<LibraryItem> add(LibraryItem item) async {
    final stored = item.copyWith(dirty: true, updatedAt: item.modifiedAt);
    await _database.into(_database.items).insert(companionFor(stored));
    await _enqueue(stored.id, 'upsert');
    return stored;
  }

  @override
  Future<LibraryItem> update(LibraryItem item) async {
    final stored = item.copyWith(
      dirty: true,
      updatedAt: DateTime.now().toUtc(),
    );
    await _database.into(_database.items).insert(
      companionFor(stored),
      mode: InsertMode.insertOrReplace,
    );
    await _enqueue(stored.id, 'upsert');
    return stored;
  }

  @override
  Future<void> delete(String id) async {
    final now = DateTime.now().toUtc();
    await (_database.update(_database.items)..where((row) => row.id.equals(id)))
        .write(
          ItemsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            dirty: const Value(true),
          ),
        );
    await _enqueue(id, 'delete');
  }

  @override
  Future<LibraryItem?> findAny(String id) async {
    final row = await (_database.select(_database.items)
          ..where((item) => item.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return libraryItemFromRow(row);
  }

  @override
  Future<List<OutboxJob>> pendingJobs() async {
    final rows = await (_database.select(_database.outboxEntries)
          ..orderBy([(row) => OrderingTerm.asc(row.id)]))
        .get();
    return [
      for (final row in rows)
        OutboxJob(id: row.id, itemId: row.itemId, operation: row.operation),
    ];
  }

  @override
  Future<void> removeJob(int id) {
    return (_database.delete(_database.outboxEntries)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  @override
  Future<void> applyRemote(LibraryItem item) async {
    final clean = item.copyWith(dirty: false);
    await _database.into(_database.items).insert(
      companionFor(clean),
      mode: InsertMode.insertOrReplace,
    );
    await (_database.delete(_database.outboxEntries)
          ..where((row) => row.itemId.equals(item.id)))
        .go();
  }

  Future<void> _enqueue(String itemId, String operation) {
    return _database.into(_database.outboxEntries).insert(
      OutboxEntriesCompanion.insert(
        itemId: itemId,
        operation: operation,
        enqueuedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
