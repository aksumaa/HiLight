import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'recognition.dart';

/// On-device Latin OCR. This build links ML Kit's Latin model only.
class MlKitOcrService implements OcrService {
  @override
  String get id => 'mlkit-latin';

  @override
  bool get requiresNetwork => false;

  @override
  Set<String> get expectedLanguageCodes => OcrRouter.onDeviceLanguageCodes;

  @override
  Future<RecognitionResult> recognize({
    required String imagePath,
    required String languageCode,
  }) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final image = InputImage.fromFilePath(imagePath);
      final recognized = await recognizer.processImage(image);
      final text = recognized.text.trim();
      if (text.isEmpty) return const RecognitionResult.empty();
      return RecognitionResult.recognized(text);
    } finally {
      await recognizer.close();
    }
  }
}
