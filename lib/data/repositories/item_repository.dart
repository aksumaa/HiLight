import '../models/library_item.dart';

abstract class ItemRepository {
  Stream<List<LibraryItem>> watchAll();

  Future<LibraryItem> add(LibraryItem item);

  Future<LibraryItem> update(LibraryItem item);

  Future<void> delete(String id);

  Future<LibraryItem?> findAny(String id);

  Future<List<OutboxJob>> pendingJobs();

  Future<void> removeJob(int id);

  Future<void> applyRemote(LibraryItem item);
}

class OutboxJob {
  const OutboxJob({required this.id, required this.itemId, required this.operation});

  final int id;
  final String itemId;
  final String operation;
}
