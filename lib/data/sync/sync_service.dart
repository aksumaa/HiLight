import 'package:shared_preferences/shared_preferences.dart';

import '../remote/api_client.dart';
import '../repositories/item_repository.dart';
import 'sync_merge.dart';

enum SyncOutcome { done, needsAccount, failed }

class SyncService {
  SyncService({
    required ApiClient api,
    required ItemRepository items,
    required SharedPreferences preferences,
  }) : _api = api,
       _items = items,
       _preferences = preferences;

  static const cursorKey = 'sync_cursor';

  final ApiClient _api;
  final ItemRepository _items;
  final SharedPreferences _preferences;

  Future<SyncOutcome> run() async {
    final token = await _api.bearer();
    if (token == null) return SyncOutcome.needsAccount;
    try {
      final jobs = await _items.pendingJobs();
      for (final job in jobs) {
        final item = await _items.findAny(job.itemId);
        if (item != null) {
          await _api.pushItem(item);
        }
        await _items.removeJob(job.id);
      }
      var offset = 0;
      String? serverTime;
      while (true) {
        final page = await _api.pullItems(
          updatedSince: _preferences.getString(cursorKey),
          offset: offset,
        );
        serverTime = page.serverTime ?? serverTime;
        for (final remote in page.items) {
          final local = await _items.findAny(remote.id);
          if (remoteWins(
            localUpdated: local?.modifiedAt,
            remoteUpdated: remote.modifiedAt,
          )) {
            await _items.applyRemote(remote);
          }
        }
        if (page.nextOffset == null) break;
        offset = page.nextOffset!;
      }
      if (serverTime != null) {
        await _preferences.setString(cursorKey, serverTime);
      }
      return SyncOutcome.done;
    } on Object {
      return SyncOutcome.failed;
    }
  }
}
