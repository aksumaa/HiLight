import 'package:dio/dio.dart';

import 'vocab_word.dart';

class LookupException implements Exception {
  const LookupException(this.message);

  final String message;
}

abstract class WordLookupService {
  Future<LookupResult> lookup({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
    String? sentence,
  });
}

class FakeWordLookupService implements WordLookupService {
  const FakeWordLookupService();

  @override
  Future<LookupResult> lookup({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
    String? sentence,
  }) async {
    return LookupResult(
      word: word,
      translation: '$word ($targetLanguage)',
      definition: 'A test definition of $word.',
      example: sentence ?? 'This is $word.',
      partOfSpeech: 'noun',
    );
  }
}

class RemoteWordLookupService implements WordLookupService {
  RemoteWordLookupService({required this.dio, required this.bearer});

  final Dio dio;
  final Future<String?> Function() bearer;

  @override
  Future<LookupResult> lookup({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
    String? sentence,
  }) async {
    try {
      final token = await bearer();
      final response = await dio.post<Map<String, dynamic>>(
        '/dictionary/lookup',
        data: {
          'word': word,
          'source_language': sourceLanguage,
          'target_language': targetLanguage,
          'sentence': ?sentence,
        },
        options: Options(headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data == null) throw const LookupException('offline');
      return LookupResult(
        word: data['word'] as String? ?? word,
        translation: data['translation'] as String? ?? '',
        definition: data['definition'] as String? ?? '',
        example: data['example'] as String? ?? '',
        partOfSpeech: data['part_of_speech'] as String? ?? '',
      );
    } on DioException {
      throw const LookupException('offline');
    }
  }
}
