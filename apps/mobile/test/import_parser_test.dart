import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/features/import/domain/clipping_parser.dart';

void main() {
  test('kindle clippings keep the page and drop a repeated sentence', () {
    final parsed = parseKindleClippings(File('test/fixtures/clippings.txt').readAsStringSync());
    final preview = dropDuplicates(parsed);
    expect(parsed, hasLength(3));
    expect(preview.highlights, hasLength(2));
    expect(preview.skippedDuplicates, 1);
    expect(preview.highlights.first.title, 'Original Notes');
    expect(preview.highlights.first.author, 'A. Reader');
    expect(preview.highlights.first.page, 3);
  });

  test('csv and markdown parse the sample files', () {
    final csv = parseHighlightCsv(File('test/fixtures/highlights.csv').readAsStringSync());
    final markdown = parseHighlightMarkdown(File('test/fixtures/highlights.md').readAsStringSync());
    expect(csv.first.text, contains('old library'));
    expect(markdown, hasLength(2));
    expect(markdown.last.title, 'Field Guide');
    expect(markdown.last.author, 'A. Reader');
  });

  test('an existing highlight is treated as a duplicate', () {
    final incoming = parseHighlightCsv(File('test/fixtures/highlights.csv').readAsStringSync());
    final preview = dropDuplicates(
      incoming,
      existingKeys: {highlightKey('Original Notes', incoming.first.text)},
    );
    expect(preview.skippedDuplicates, 1);
    expect(preview.highlights, hasLength(1));
  });
}
