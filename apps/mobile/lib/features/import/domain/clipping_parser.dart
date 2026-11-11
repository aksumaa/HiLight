class ImportedHighlight {
  const ImportedHighlight({
    required this.title,
    required this.text,
    this.author,
    this.page,
  });

  final String title;
  final String text;
  final String? author;
  final int? page;
}

class ImportPreview {
  const ImportPreview({required this.highlights, required this.skippedDuplicates});

  final List<ImportedHighlight> highlights;
  final int skippedDuplicates;
}

List<ImportedHighlight> parseKindleClippings(String source) {
  final blocks = source.split(RegExp(r'={5,}'));
  final highlights = <ImportedHighlight>[];
  for (final block in blocks) {
    final lines = [
      for (final line in block.split(RegExp(r'\r?\n')))
        if (line.trim().isNotEmpty) line.trim(),
    ];
    if (lines.length < 2) continue;
    final titleLine = lines.first;
    final meta = lines.length > 2 ? lines[1] : '';
    final text = lines.last;
    if (text == titleLine || text.startsWith('- ')) continue;
    final author = _author(titleLine);
    highlights.add(
      ImportedHighlight(
        title: _title(titleLine),
        author: author,
        text: text,
        page: _page(meta),
      ),
    );
  }
  return highlights;
}

List<ImportedHighlight> parseHighlightCsv(String source) {
  final rows = _csvRows(source);
  if (rows.isEmpty) return const [];
  final header = rows.first.map((cell) => cell.trim().toLowerCase()).toList();
  final titleIndex = header.indexOf('title');
  final textIndex = header.indexOf('text');
  if (titleIndex < 0 || textIndex < 0) return const [];
  final authorIndex = header.indexOf('author');
  final pageIndex = header.indexOf('page');
  return [
    for (final row in rows.skip(1))
      if (textIndex < row.length && row[textIndex].trim().isNotEmpty && titleIndex < row.length)
        ImportedHighlight(
          title: row[titleIndex].trim().isEmpty ? 'Imported' : row[titleIndex].trim(),
          text: row[textIndex].trim(),
          author: authorIndex >= 0 && authorIndex < row.length && row[authorIndex].trim().isNotEmpty
              ? row[authorIndex].trim()
              : null,
          page: pageIndex >= 0 && pageIndex < row.length ? int.tryParse(row[pageIndex].trim()) : null,
        ),
  ];
}

List<ImportedHighlight> parseHighlightMarkdown(String source) {
  final highlights = <ImportedHighlight>[];
  String? title;
  String? author;
  var sawHighlight = false;
  for (final raw in source.split(RegExp(r'\r?\n'))) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    if (line.startsWith('# ')) {
      title = line.substring(2).trim();
      author = null;
      sawHighlight = false;
      continue;
    }
    if (line.startsWith('> ') || line.startsWith('- ')) {
      sawHighlight = true;
      highlights.add(
        ImportedHighlight(
          title: title == null || title.isEmpty ? 'Imported' : title,
          author: author,
          text: line.substring(2).trim(),
        ),
      );
      continue;
    }
    if (title != null && !sawHighlight && author == null) author = line;
  }
  return [for (final item in highlights) if (item.text.isNotEmpty) item];
}

ImportPreview dropDuplicates(
  List<ImportedHighlight> incoming, {
  Set<String> existingKeys = const {},
}) {
  final seen = {...existingKeys};
  final kept = <ImportedHighlight>[];
  var skipped = 0;
  for (final item in incoming) {
    final key = highlightKey(item.title, item.text);
    if (seen.contains(key)) {
      skipped += 1;
      continue;
    }
    seen.add(key);
    kept.add(item);
  }
  return ImportPreview(highlights: kept, skippedDuplicates: skipped);
}

String highlightKey(String title, String text) => '${title.trim().toLowerCase()}|${text.trim().toLowerCase()}';

String _title(String line) {
  final match = RegExp(r'^(.*)\(([^)]+)\)\s*$').firstMatch(line);
  final title = match?.group(1)?.trim() ?? line.trim();
  return title.isEmpty ? 'Imported' : title;
}

String? _author(String line) {
  final match = RegExp(r'^(.*)\(([^)]+)\)\s*$').firstMatch(line);
  final author = match?.group(2)?.trim();
  if (author == null || author.isEmpty) return null;
  return author;
}

int? _page(String meta) {
  final match = RegExp(r'page\s+(\d+)', caseSensitive: false).firstMatch(meta);
  return match == null ? null : int.tryParse(match.group(1)!);
}

List<List<String>> _csvRows(String source) {
  final rows = <List<String>>[];
  final row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < source.length; i++) {
    final char = source[i];
    if (char == '"') {
      if (quoted && i + 1 < source.length && source[i + 1] == '"') {
        cell.write('"');
        i += 1;
      } else {
        quoted = !quoted;
      }
      continue;
    }
    if (char == ',' && !quoted) {
      row.add(cell.toString());
      cell.clear();
      continue;
    }
    if ((char == '\n' || char == '\r') && !quoted) {
      if (char == '\r' && i + 1 < source.length && source[i + 1] == '\n') i += 1;
      row.add(cell.toString());
      cell.clear();
      if (row.any((value) => value.trim().isNotEmpty)) rows.add([...row]);
      row.clear();
      continue;
    }
    cell.write(char);
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    if (row.any((value) => value.trim().isNotEmpty)) rows.add(row);
  }
  return rows;
}
