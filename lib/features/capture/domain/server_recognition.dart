import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'recognition.dart';

/// POSTs an image to `POST {apiBase}/ocr`.
///
/// The response shape is an assumption until the backend exists:
/// `200` and JSON `{ "text": "..." }`.
/// Multipart fields: `image` (file) and `language` (`en`, `ru`, or `uz`).
class ServerOcrService implements OcrService {
  ServerOcrService({
    required this.apiBase,
    required this.useFake,
    required this.fake,
    required this.client,
    this.bearer,
    this.timeout = const Duration(seconds: 30),
  });

  final String apiBase;
  final bool useFake;
  final OcrService fake;
  final http.Client client;
  final Future<String?> Function()? bearer;
  final Duration timeout;

  @override
  String get id => 'server-ocr';

  @override
  bool get requiresNetwork => !useFake;

  @override
  Set<String> get expectedLanguageCodes => const {'en', 'ru', 'uz'};

  @override
  Future<RecognitionResult> recognize({
    required String imagePath,
    required String languageCode,
  }) async {
    if (useFake) {
      return fake.recognize(imagePath: imagePath, languageCode: languageCode);
    }
    final token = bearer == null ? null : await bearer!();
    if (token == null) return const RecognitionResult.failed();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBase/ocr'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['language'] = languageCode;
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      final response = await client.send(request).timeout(timeout);
      final body = await response.stream.bytesToString();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const RecognitionResult.failed();
      }
      return resultFromBody(body);
    } on SocketException {
      return const RecognitionResult.pending();
    } on http.ClientException {
      return const RecognitionResult.pending();
    } on HandshakeException {
      return const RecognitionResult.pending();
    } on TimeoutException {
      return const RecognitionResult.pending();
    }
  }
}

/// POSTs audio to `POST {apiBase}/stt`.
///
/// Assumed contract: multipart `audio` plus `language`,
/// `200` JSON `{ "text": "..." }`.
class ServerSttService implements SttService {
  ServerSttService({
    required this.apiBase,
    required this.useFake,
    required this.fake,
    required this.client,
    this.bearer,
    this.timeout = const Duration(seconds: 60),
  });

  final String apiBase;
  final bool useFake;
  final SttService fake;
  final http.Client client;
  final Future<String?> Function()? bearer;
  final Duration timeout;

  @override
  String get id => 'server-stt';

  @override
  bool get requiresNetwork => !useFake;

  @override
  Set<String> get expectedLanguageCodes => const {'en', 'ru', 'uz'};

  @override
  Future<RecognitionResult> transcribe({
    required String audioPath,
    required String languageCode,
  }) async {
    if (useFake) {
      return fake.transcribe(audioPath: audioPath, languageCode: languageCode);
    }
    final token = bearer == null ? null : await bearer!();
    if (token == null) return const RecognitionResult.failed();
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$apiBase/stt'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['language'] = languageCode;
      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
      final response = await client.send(request).timeout(timeout);
      final body = await response.stream.bytesToString();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const RecognitionResult.failed();
      }
      return resultFromBody(body);
    } on SocketException {
      return const RecognitionResult.pending();
    } on http.ClientException {
      return const RecognitionResult.pending();
    } on HandshakeException {
      return const RecognitionResult.pending();
    } on TimeoutException {
      return const RecognitionResult.pending();
    }
  }
}

RecognitionResult resultFromBody(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map || decoded['text'] is! String) {
    return const RecognitionResult.failed();
  }
  final text = (decoded['text'] as String).trim();
  if (text.isEmpty) return const RecognitionResult.empty();
  return RecognitionResult.recognized(text);
}
