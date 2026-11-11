import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/data/models/library_item.dart';
import 'package:hilight/features/widget/domain/widget_snapshot.dart';

LibraryItem note(String id, String text) {
  return LibraryItem(
    id: id,
    type: ItemType.note,
    source: ItemSource.manual,
    text: text,
    languageCode: 'en',
    createdAt: DateTime.utc(2026),
    recognitionStatus: RecognitionStatus.recognized,
  );
}

void main() {
  test('the quote of the day stays on the same sentence for one day', () {
    final items = [note('a', 'First light'), note('b', 'Second light')];
    final morning = DateTime(2026, 3, 2, 8);
    final evening = DateTime(2026, 3, 2, 21);
    expect(quoteOfDay(items, morning), quoteOfDay(items, evening));
    expect(quoteOfDay(const [], morning), isNull);
  });
}
