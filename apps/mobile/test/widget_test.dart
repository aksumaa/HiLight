import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/data/sync/sync_merge.dart';

void main() {
  test('sync keeps the later write', () {
    expect(
      remoteWins(
        localUpdated: DateTime.utc(2026, 1, 2),
        remoteUpdated: DateTime.utc(2026, 1, 3),
      ),
      isTrue,
    );
  });
}
