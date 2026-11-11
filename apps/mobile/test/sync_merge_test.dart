import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/data/sync/sync_merge.dart';

void main() {
  test('a newer remote item replaces the local copy', () {
    final local = DateTime.utc(2026, 1, 1);
    final remote = DateTime.utc(2026, 6, 1);
    expect(remoteWins(localUpdated: local, remoteUpdated: remote), isTrue);
  });

  test('a newer local item is kept', () {
    final local = DateTime.utc(2026, 6, 1);
    final remote = DateTime.utc(2026, 1, 1);
    expect(remoteWins(localUpdated: local, remoteUpdated: remote), isFalse);
  });

  test('equal timestamps take the remote copy', () {
    final stamp = DateTime.utc(2026, 3, 1);
    expect(remoteWins(localUpdated: stamp, remoteUpdated: stamp), isTrue);
  });

  test('a missing local item takes the remote copy', () {
    expect(
      remoteWins(localUpdated: null, remoteUpdated: DateTime.utc(2026, 1, 1)),
      isTrue,
    );
  });
}
