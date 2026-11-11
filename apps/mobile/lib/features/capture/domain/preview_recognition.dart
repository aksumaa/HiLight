import 'recognition.dart';

/// Canned text used while `USE_FAKE_OCR` / `USE_FAKE_STT` are on.
/// The edit screen also shows a banner so this is not mistaken for a real read.
class PreviewOcrService implements OcrService {
  @override
  String get id => 'preview-ocr';

  @override
  bool get requiresNetwork => false;

  @override
  Set<String> get expectedLanguageCodes => const {'en', 'ru', 'uz'};

  @override
  Future<RecognitionResult> recognize({
    required String imagePath,
    required String languageCode,
  }) async {
    return RecognitionResult.recognized(
      _samples[languageCode] ?? _samples['en']!,
      usedStub: true,
    );
  }
}

class PreviewSttService implements SttService {
  @override
  String get id => 'preview-stt';

  @override
  bool get requiresNetwork => false;

  @override
  Set<String> get expectedLanguageCodes => const {'en', 'ru', 'uz'};

  @override
  Future<RecognitionResult> transcribe({
    required String audioPath,
    required String languageCode,
  }) async {
    return RecognitionResult.recognized(
      _samples[languageCode] ?? _samples['en']!,
      usedStub: true,
    );
  }
}

const _samples = {
  'en': 'The morning light stayed on the page long after the lamp was out.',
  'ru':
      'Утренний свет оставался на странице ещё долго после того, как лампа погасла.',
  'uz': 'Chiroq oʻchganidan keyin ham sahifada ertalabki yorugʻlik turardi.',
};
