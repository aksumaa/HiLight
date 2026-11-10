import 'package:shared_preferences/shared_preferences.dart';

import '../remote/api_client.dart';
import '../repositories/item_repository.dart';
import 'sync_merge.dart';

enum SyncOutcome { done, needsAccount, failed }

class SyncService {
  SyncService({
    required this.api,
    required this.items,
    required this.preferences,
  });

  static const cursorKey = 'sync_cursor';

  final ApiClient api;
  final ItemRepository items;
  final SharedPreferences preferences;

  Future<SyncOutcome> run() async {
    final token = await api.bearer();
    if (token == null) return SyncOutcome.needsAccount;
    try {
      final jobs = await items.pendingJobs();
      for (final job in jobs) {
        final item = await items.findAny(job.itemId);
        if (item != null) {
          await api.pushItem(item);
        }
        await items.removeJob(job.id);
      }
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
}
