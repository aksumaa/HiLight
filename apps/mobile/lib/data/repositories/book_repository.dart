import 'package:drift/drift.dart';

import '../../features/books/domain/shelf_book.dart';
import '../db/app_database.dart';

abstract class BookRepository {
  Stream<List<ShelfBook>> watchAll();

  Future<ShelfBook> add(ShelfBook book);

  Future<ShelfBook?> find(String id);

  Future<ShelfBook?> findAny(String id);

  Future<void> applyRemote(ShelfBook book);

  Map<String, dynamic> payload(ShelfBook book);
}

class DriftBookRepository implements BookRepository {
  DriftBookRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<ShelfBook>> watchAll() {
    final query = _database.select(_database.books)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
    return query.watch().map((rows) => rows.map(_book).toList());
  }

  @override
  Future<ShelfBook> add(ShelfBook book) async {
    final stored = book.copyWith(dirty: true, updatedAt: DateTime.now().toUtc());
    await _database.into(_database.books).insert(
      BooksCompanion.insert(
        id: stored.id,
        title: stored.title,
        author: Value(stored.author),
        coverUrl: Value(stored.coverUrl),
        totalPages: Value(stored.totalPages),
        isbn: Value(stored.isbn),
        createdAt: stored.createdAt,
        updatedAt: stored.updatedAt,
        dirty: const Value(true),
      ),
      mode: InsertMode.insertOrReplace,
    );
    await _database.into(_database.outboxEntries).insert(
      OutboxEntriesCompanion.insert(
        itemId: stored.id,
        operation: 'upsert',
        entityType: const Value('book'),
        enqueuedAt: DateTime.now().toUtc(),
      ),
    );
    return stored;
  }

  @override
  Future<ShelfBook?> find(String id) async {
    final row = await (_database.select(_database.books)..where((book) => book.id.equals(id)))
        .getSingleOrNull();
    if (row == null || row.deletedAt != null) return null;
    return _book(row);
  }

  @override
  Future<ShelfBook?> findAny(String id) async {
    final row = await (_database.select(_database.books)..where((book) => book.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _book(row);
  }

  @override
  Future<void> applyRemote(ShelfBook book) async {
    await _database.into(_database.books).insert(
      BooksCompanion.insert(
        id: book.id,
        title: book.title,
        author: Value(book.author),
        coverUrl: Value(book.coverUrl),
        totalPages: Value(book.totalPages),
        isbn: Value(book.isbn),
        createdAt: book.createdAt,
        updatedAt: book.updatedAt,
        deletedAt: Value(book.deletedAt),
        dirty: const Value(false),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Map<String, dynamic> payload(ShelfBook book) {
    return {
      'title': book.title,
      'author': book.author,
      'cover_url': book.coverUrl,
      'total_pages': book.totalPages,
      'isbn': book.isbn,
      'updated_at': book.updatedAt.toUtc().toIso8601String(),
      'deleted_at': book.deletedAt?.toUtc().toIso8601String(),
    };
  }

  ShelfBook _book(Book row) {
    return ShelfBook(
      id: row.id,
      title: row.title,
      author: row.author,
      coverUrl: row.coverUrl,
      totalPages: row.totalPages,
      isbn: row.isbn,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      dirty: row.dirty,
    );
  }
}
