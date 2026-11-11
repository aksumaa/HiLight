import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/library_item.dart';
import 'token_store.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({required this.dio, required this.tokens});

  final Dio dio;
  final TokenStore tokens;

  Future<TokenPair> register({required String email, required String password}) {
    return _session('post', '/auth/register', {'email': email, 'password': password});
  }

  Future<TokenPair> login({required String email, required String password}) {
    return _session('post', '/auth/login', {'email': email, 'password': password});
  }

  Future<void> logout() => tokens.clear();

  Future<String?> bearer() async {
    final access = await tokens.readAccess();
    if (access != null && !_expired(access)) return access;
    final refresh = await tokens.readRefresh();
    if (refresh == null) return null;
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final pair = _pair(response.data);
      await tokens.write(pair);
      return pair.access;
    } on DioException {
      await tokens.clear();
      return null;
    }
  }

  Future<void> pushItem(LibraryItem item) async {
    final token = await bearer();
    if (token == null) throw ApiException('Sign in required.');
    if (item.deletedAt != null) {
      try {
        await dio.delete(
          '/items/${item.id}',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } on DioException catch (error) {
        // The row was never uploaded, or already removed. Do not block the queue.
        if (error.response?.statusCode != 404) rethrow;
      }
      return;
    }
    await dio.post(
      '/items',
      data: _body(item),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<RemotePage> pullItems({String? updatedSince, int offset = 0}) async {
    final token = await bearer();
    if (token == null) throw ApiException('Sign in required.');
    final response = await dio.get<Map<String, dynamic>>(
      '/items',
      queryParameters: {
        'limit': 100,
        'offset': offset,
        'updated_since': ?updatedSince,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = response.data ?? const <String, dynamic>{};
    final rows = (data['items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(itemFromJson)
        .toList();
    return RemotePage(
      items: rows,
      nextOffset: data['next_offset'] as int?,
      serverTime: data['server_time'] as String?,
    );
  }

  Future<void> putRecord(String collection, String id, Map<String, dynamic> body) async {
    final token = await bearer();
    if (token == null) throw ApiException('Sign in required.');
    await dio.put(
      '/$collection/$id',
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<Map<String, dynamic>>> pullRecords(
    String collection, {
    String? updatedSince,
  }) async {
    final token = await bearer();
    if (token == null) throw ApiException('Sign in required.');
    final response = await dio.get<Map<String, dynamic>>(
      '/$collection',
      queryParameters: {'limit': 100, 'updated_since': ?updatedSince},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final rows = response.data?['items'];
    if (rows is! List) return const [];
    return rows.cast<Map<String, dynamic>>();
  }

  Future<TokenPair> _session(String method, String path, Map<String, dynamic> body) async {
    final response = await dio.post<Map<String, dynamic>>(path, data: body);
    final pair = _pair(response.data);
    await tokens.write(pair);
    return pair;
  }

  TokenPair _pair(Map<String, dynamic>? data) {
    if (data == null || data['access_token'] is! String || data['refresh_token'] is! String) {
      throw ApiException('The server did not return tokens.');
    }
    return TokenPair(access: data['access_token'] as String, refresh: data['refresh_token'] as String);
  }
}

class RemotePage {
  const RemotePage({required this.items, required this.nextOffset, required this.serverTime});

  final List<LibraryItem> items;
  final int? nextOffset;
  final String? serverTime;
}

Map<String, dynamic> _body(LibraryItem item) {
  return {
    'id': item.id,
    'type': item.type.name,
    'source': item.source.name,
    'text': item.text,
    'page': item.page,
    'language': item.languageCode,
    'meta': {
      'tag': item.tag,
      'recognition_status': item.recognitionStatus.name,
      'highlight_color': item.highlightColor.name,
      'note': item.note,
      'favorite': item.favorite,
      'chapter': item.chapter,
      'book_id': item.bookId,
    },
    'updated_at': item.modifiedAt.toUtc().toIso8601String(),
  };
}

LibraryItem itemFromJson(Map<String, dynamic> json) {
  final meta = json['meta'];
  final tag = meta is Map ? meta['tag'] as String? : null;
  final statusName = meta is Map ? meta['recognition_status'] as String? : null;
  final colorName = meta is Map ? meta['highlight_color'] as String? : null;
  return LibraryItem(
    id: json['id'] as String,
    type: ItemType.values.byName(json['type'] as String),
    source: ItemSource.values.byName(json['source'] as String),
    text: (json['text'] as String?) ?? '',
    page: json['page'] as int?,
    languageCode: json['language'] as String,
    audioPath: json['audio_url'] as String?,
    imagePath: json['image_url'] as String?,
    tag: tag,
    highlightColor: HighlightColor.values.byName(colorName ?? 'gold'),
    note: meta is Map ? meta['note'] as String? : null,
    favorite: meta is Map && meta['favorite'] == true,
    chapter: meta is Map ? meta['chapter'] as String? : null,
    bookId: meta is Map ? meta['book_id'] as String? : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
    recognitionStatus: RecognitionStatus.values.byName(statusName ?? 'recognized'),
  );
}

bool _expired(String jwt) {
  try {
    final parts = jwt.split('.');
    if (parts.length < 2) return true;
    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (payload is! Map || payload['exp'] is! int) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000, isUtc: true);
    return DateTime.now().toUtc().isAfter(expiry.subtract(const Duration(seconds: 30)));
  } on FormatException {
    return true;
  }
}
