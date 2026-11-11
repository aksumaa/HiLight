import 'package:shared_preferences/shared_preferences.dart';

import '../remote/api_client.dart';
import '../repositories/book_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/study_repository.dart';
import '../../features/books/domain/shelf_book.dart';
import 'sync_merge.dart';

enum SyncOutcome { done, needsAccount, failed }

class SyncService {
  SyncService({
    required this.api,
    required this.items,
    required this.preferences,
    this.books,
    this.study,
  });

  static const cursorKey = 'sync_cursor';

  final ApiClient api;
  final ItemRepository items;
  final SharedPreferences preferences;
  final BookRepository? books;
  final StudyRepository? study;

  Future<SyncOutcome> run() async {
    final token = await api.bearer();
    if (token == null) return SyncOutcome.needsAccount;
    try {
      final jobs = await items.pendingJobs();
      for (final job in jobs) {
        if (job.entityType != 'item') {
          await _pushStudy(job);
          continue;
        }
        final item = await items.findAny(job.itemId);
        if (item != null) {
          await api.pushItem(item);
        }
        await items.removeJob(job.id);
      }
      await _pullStudy();
      var offset = 0;
      String? serverTime;
      while (true) {
        final page = await api.pullItems(
          updatedSince: preferences.getString(cursorKey),
          offset: offset,
        );
        serverTime = page.serverTime ?? serverTime;
        for (final remote in page.items) {
          final local = await items.findAny(remote.id);
          if (remoteWins(
            localUpdated: local?.modifiedAt,
            remoteUpdated: remote.modifiedAt,
          )) {
            await items.applyRemote(remote);
          }
        }
        if (page.nextOffset == null) break;
        offset = page.nextOffset!;
      }
      if (serverTime != null) {
        await preferences.setString(cursorKey, serverTime);
      }
      return SyncOutcome.done;
    } on Object {
      return SyncOutcome.failed;
    }
  }

  Future<void> _pushStudy(OutboxJob job) async {
    final books = this.books;
    final study = this.study;
    Map<String, dynamic>? body;
    var collection = job.entityType;
    if (job.entityType == 'book' && books != null) {
      collection = 'books';
      final book = await books.findAny(job.itemId);
      body = book == null ? null : books.payload(book);
    } else if (job.entityType == 'word' && study != null) {
      collection = 'words';
      body = await study.wordPayload(job.itemId);
    } else if (job.entityType == 'card' && study != null) {
      collection = 'cards';
      body = await study.cardPayload(job.itemId);
    } else if (job.entityType == 'review_log' && study != null) {
      collection = 'review-logs';
      body = await study.logPayload(job.itemId);
    } else {
      return;
    }
    if (body != null) await api.putRecord(collection, job.itemId, body);
    await items.removeJob(job.id);
  }

  Future<void> _pullStudy() async {
    final books = this.books;
    final study = this.study;
    if (books != null) {
      for (final row in await api.pullRecords('books', updatedSince: preferences.getString('sync_books'))) {
        final remote = _book(row);
        final local = await books.findAny(remote.id);
        if (remoteWins(localUpdated: local?.updatedAt, remoteUpdated: remote.updatedAt)) {
          await books.applyRemote(remote);
        }
      }
    }
    if (study == null) return;
    for (final row in await api.pullRecords('words', updatedSince: preferences.getString('sync_words'))) {
      await study.applyWord(row);
    }
    for (final row in await api.pullRecords('cards', updatedSince: preferences.getString('sync_cards'))) {
      await study.applyCard(row);
    }
    for (final row in await api.pullRecords('review-logs', updatedSince: preferences.getString('sync_logs'))) {
      await study.applyLog(row);
    }
  }

  ShelfBook _book(Map<String, dynamic> json) {
    return ShelfBook(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      coverUrl: json['cover_url'] as String?,
      totalPages: json['total_pages'] as int?,
      isbn: json['isbn'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
    );
  }
}
