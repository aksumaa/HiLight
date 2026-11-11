import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/data/models/library_item.dart';
import 'package:hilight/features/books/domain/shelf_book.dart';
import 'package:hilight/features/export/domain/exporters.dart';
import 'package:hilight/features/study/domain/vocab_word.dart';

LibraryItem quote(String text, {String? bookId, int? page}) {
  return LibraryItem(
    id: text,
    type: ItemType.quote,
    source: ItemSource.manual,
    text: text,
    page: page,
    bookId: bookId,
    languageCode: 'en',
    createdAt: DateTime.utc(2026),
    recognitionStatus: RecognitionStatus.recognized,
  );
}

void main() {
  test('obsidian files are one note per book and notion is one document', () {
    final now = DateTime.utc(2026);
    final books = [
      ShelfBook(id: 'b', title: 'Field Guide', author: 'A. Reader', createdAt: now, updatedAt: now),
    ];
    final grouped = groupHighlights(books, [
      quote('The library stayed open', bookId: 'b', page: 3),
      quote('A loose sentence'),
    ]);
    final files = obsidianFiles(grouped);
    expect(files.keys, contains('Field Guide.md'));
    expect(files['Field Guide.md'], contains('> The library stayed open'));
    expect(files['Loose notes.md'], contains('A loose sentence'));
    final notion = notionMarkdown(grouped);
    expect(notion, contains('# Field Guide'));
    expect(notion, contains('---'));
  });

  test('anki csv keeps commas inside quotes', () {
    final now = DateTime.utc(2026);
    final csv = ankiCsv([
      VocabWord(
        id: '1',
        word: 'habitat, wild',
        sourceLanguage: 'en',
        targetLanguage: 'en',
        translation: 'a "place"',
        tags: 'environment',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    expect(csv.split('\n').first, 'front,back,tags');
    expect(csv, contains('"habitat, wild"'));
    expect(csv, contains('"a ""place"""'));
  });
}
