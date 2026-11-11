import 'package:dio/dio.dart';

class TutorReply {
  const TutorReply({
    required this.text,
    this.offline = false,
    this.limitReached = false,
    this.versions = const [],
    this.disclaimer = '',
    this.kind = 'general',
    this.sources = const [],
  });

  final String text;
  final bool offline;
  final bool limitReached;
  final List<TutorVersion> versions;
  final String disclaimer;
  final String kind;
  final List<String> sources;
}

class TutorVersion {
  const TutorVersion({required this.text, required this.explanation});

  final String text;
  final String explanation;
}

class TutorService {
  TutorService({required this.dio, required this.bearer});

  final Dio dio;
  final Future<String?> Function() bearer;

  Future<TutorReply> chat({
    required String text,
    required String mode,
    required String targetLanguage,
  }) async {
    final local = TutorReply(text: _local(text, mode, targetLanguage), offline: true);
    try {
      final token = await bearer();
      if (token == null) return local;
      final response = await dio.post<Map<String, dynamic>>(
        '/ai/chat',
        data: {'text': text, 'mode': mode, 'target_language': targetLanguage},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data == null) return local;
      return TutorReply(text: data['text'] as String? ?? '', disclaimer: data['disclaimer'] as String? ?? '');
    } on DioException catch (error) {
      if (error.response?.statusCode == 429) return const TutorReply(text: '', limitReached: true);
      return local;
    }
  }

  Future<TutorReply> rewrite({
    required String sentence,
    String task = '',
    String topic = '',
  }) async {
    try {
      final token = await bearer();
      if (token == null) return _localRewrite(sentence);
      final response = await dio.post<Map<String, dynamic>>(
        '/ai/rewrite',
        data: {'sentence': sentence, 'task': task, 'topic': topic},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data == null) return _localRewrite(sentence);
      final versions = data['versions'];
      return TutorReply(
        text: '',
        disclaimer: data['disclaimer'] as String? ?? '',
        versions: [
          if (versions is List)
            for (final row in versions)
              if (row is Map)
                TutorVersion(
                  text: row['text'] as String? ?? '',
                  explanation: row['explanation'] as String? ?? '',
                ),
        ],
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 429) return const TutorReply(text: '', limitReached: true);
      return _localRewrite(sentence);
    }
  }

  Future<List<String>> searchIds(String query) async {
    try {
      final token = await bearer();
      if (token == null) return const [];
      final response = await dio.post<Map<String, dynamic>>(
        '/search',
        data: {'query': query, 'limit': 5},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final hits = response.data?['hits'];
      if (hits is! List) return const [];
      return [for (final hit in hits) if (hit is Map && hit['id'] is String) hit['id'] as String];
    } on DioException {
      return const [];
    }
  }

  TutorReply _localRewrite(String sentence) {
    return TutorReply(
      text: '',
      offline: true,
      versions: [
        TutorVersion(text: '$sentence because the point is easier to see.', explanation: 'Adds a reason.'),
        TutorVersion(text: 'In short, $sentence', explanation: 'Starts with the point.'),
      ],
    );
  }

  Future<TutorReply> summarize({
    required String title,
    required String bookId,
    required List<String> notes,
    String chapter = '',
  }) {
    return _notes(
      path: '/ai/summary',
      body: {'title': title, 'book_id': bookId, 'chapter': chapter, 'notes': notes},
      offlineText: notes.isEmpty ? '' : notes.take(3).join(' '),
    );
  }

  Future<TutorReply> bookChat({
    required String title,
    required String bookId,
    required String question,
    required List<String> notes,
    String chapter = '',
  }) {
    final match = notes.where((note) => note.toLowerCase().contains(question.toLowerCase())).take(1);
    return _notes(
      path: '/ai/book-chat',
      body: {
        'title': title,
        'book_id': bookId,
        'chapter': chapter,
        'question': question,
        'notes': notes,
      },
      offlineText: match.isEmpty ? question : match.first,
    );
  }

  Future<TutorReply> _notes({
    required String path,
    required Map<String, Object> body,
    required String offlineText,
  }) async {
    final local = TutorReply(text: offlineText, offline: true, kind: offlineText.isEmpty ? 'general' : 'from_notes');
    try {
      final token = await bearer();
      if (token == null) return local;
      final response = await dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data == null) return local;
      final sources = data['sources'];
      return TutorReply(
        text: data['text'] as String? ?? '',
        kind: data['kind'] as String? ?? 'general',
        sources: [if (sources is List) for (final row in sources) if (row is String) row],
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 429) return const TutorReply(text: '', limitReached: true);
      return local;
    }
  }

  String _local(String text, String mode, String targetLanguage) {
    return switch (mode) {
      'simplify' => text.split('.').first.trim(),
      'translate' => '$text ($targetLanguage)',
      'grammar' => 'Look for the subject, the verb, and what the verb acts on.',
      'quiz' => 'Fill the gap from this sentence: $text',
      _ => 'In plain words: $text',
    };
  }
}
