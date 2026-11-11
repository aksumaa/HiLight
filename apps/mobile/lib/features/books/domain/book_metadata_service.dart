import 'dart:convert';

import 'package:http/http.dart' as http;

import 'shelf_book.dart';

abstract class BookMetadataService {
  Future<List<BookDraft>> search(String query);

  Future<BookDraft?> byIsbn(String isbn);
}

class FakeBookMetadataService implements BookMetadataService {
  const FakeBookMetadataService();

  @override
  Future<List<BookDraft>> search(String query) async {
    if (query.trim().toLowerCase() != 'test') return const [];
    return const [
      BookDraft(title: 'Test Book', author: 'A. Reader', totalPages: 320, isbn: '9780000000000'),
    ];
  }

  @override
  Future<BookDraft?> byIsbn(String isbn) async {
    if (isbn != '9780000000000') return null;
    return const BookDraft(title: 'Test Book', author: 'A. Reader', totalPages: 320, isbn: '9780000000000');
  }
}

class OpenLibraryMetadataService implements BookMetadataService {
  OpenLibraryMetadataService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<BookDraft>> search(String query) async {
    final uri = Uri.https('openlibrary.org', '/search.json', {'q': query, 'limit': '8'});
    final response = await _client.get(uri);
    if (response.statusCode != 200) return const [];
    final body = jsonDecode(response.body);
    if (body is! Map || body['docs'] is! List) return const [];
    return [
      for (final row in body['docs'] as List)
        if (row is Map && row['title'] is String)
          BookDraft(
            title: row['title'] as String,
            author: (row['author_name'] is List && (row['author_name'] as List).isNotEmpty)
                ? '${(row['author_name'] as List).first}'
                : null,
            coverUrl: row['cover_i'] is int
                ? 'https://covers.openlibrary.org/b/id/${row['cover_i']}-M.jpg'
                : null,
            totalPages: row['number_of_pages_median'] is int ? row['number_of_pages_median'] as int : null,
            isbn: (row['isbn'] is List && (row['isbn'] as List).isNotEmpty) ? '${(row['isbn'] as List).first}' : null,
          ),
    ];
  }

  @override
  Future<BookDraft?> byIsbn(String isbn) async {
    final clean = isbn.replaceAll(RegExp(r'[^0-9Xx]'), '');
    final response = await _client.get(Uri.https('openlibrary.org', '/isbn/$clean.json'));
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body);
    if (body is! Map || body['title'] is! String) return null;
    return BookDraft(title: body['title'] as String, isbn: clean);
  }
}
