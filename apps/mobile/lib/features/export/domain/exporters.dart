import '../../../data/models/library_item.dart';
import '../../books/domain/shelf_book.dart';
import '../../study/domain/vocab_word.dart';

class ExportBook {
  const ExportBook({required this.title, this.author, required this.highlights});

  final String title;
  final String? author;
  final List<LibraryItem> highlights;
}

List<ExportBook> groupHighlights(List<ShelfBook> books, List<LibraryItem> items) {
  final byBook = <String, List<LibraryItem>>{};
  final loose = <LibraryItem>[];
  for (final item in items) {
    if (item.text.trim().isEmpty) continue;
    final bookId = item.bookId;
    if (bookId == null) {
      loose.add(item);
    } else {
      byBook.putIfAbsent(bookId, () => []).add(item);
    }
  }
  return [
    for (final book in books)
      if (byBook[book.id] != null)
        ExportBook(title: book.title, author: book.author, highlights: byBook[book.id]!),
    if (loose.isNotEmpty) ExportBook(title: 'Loose notes', highlights: loose),
  ];
}

Map<String, String> obsidianFiles(List<ExportBook> books) {
  return {
    for (final book in books) _fileName(book.title): _obsidian(book),
  };
}

String notionMarkdown(List<ExportBook> books) {
  return [
    for (final book in books) ...[
      '# ${book.title}',
      if (book.author != null) book.author!,
      '',
      for (final item in book.highlights) ...[
        item.text.trim(),
        if (item.page != null) 'Page ${item.page}',
        '',
        '---',
        '',
      ],
    ],
  ].join('\n').trimRight();
}

String ankiCsv(List<VocabWord> words) {
  final lines = <String>['front,back,tags'];
  for (final word in words) {
    final back = word.translation.trim().isEmpty ? word.definition : word.translation;
    lines.add('${_csv(word.word)},${_csv(back)},${_csv(word.tags)}');
  }
  return lines.join('\n');
}

String _obsidian(ExportBook book) {
  final buffer = StringBuffer()
    ..writeln('---')
    ..writeln('title: ${_yaml(book.title)}')
    ..writeln('author: ${_yaml(book.author ?? '')}')
    ..writeln('---')
    ..writeln();
  for (final item in book.highlights) {
    buffer.writeln('> ${item.text.trim().replaceAll('\n', '\n> ')}');
    if (item.page != null) buffer.writeln('page: ${item.page}');
    if (item.note != null && item.note!.trim().isNotEmpty) buffer.writeln(item.note!.trim());
    buffer.writeln();
  }
  return buffer.toString().trimRight();
}

String _fileName(String title) {
  final cleaned = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').trim();
  return '${cleaned.isEmpty ? 'Notes' : cleaned}.md';
}

String _yaml(String value) => '"${value.replaceAll('"', '\\"')}"';

String _csv(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}
