import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/data/models/library_item.dart';
import 'package:hilight/features/library/domain/meaning.dart';

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
  test('notes that share words rank above an unrelated note', () {
    final focus = note('focus', 'The old library stayed open after dark');
    final related = relatedNotes(
      [
        focus,
        note('close', 'A library that stayed open'),
        note('far', 'The tram was late'),
      ],
      focus,
    );
    expect(related.first.id, 'close');
    expect(related.map((item) => item.id), isNot(contains('focus')));
  });
}
