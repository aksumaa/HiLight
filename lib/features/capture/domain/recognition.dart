import 'capture_event.dart';

class RecognitionResult {
  const RecognitionResult({
    required this.text,
    required this.outcome,
    this.usedStub = false,
  });

  final String text;
  final CaptureOutcome outcome;
  final bool usedStub;

  const RecognitionResult.recognized(this.text, {this.usedStub = false})
    : outcome = CaptureOutcome.recognized;

  const RecognitionResult.empty()
    : text = '',
      outcome = CaptureOutcome.empty,
      usedStub = false;

  const RecognitionResult.pending()
    : text = '',
      outcome = CaptureOutcome.pendingOffline,
      usedStub = false;

  const RecognitionResult.failed()
    : text = '',
      outcome = CaptureOutcome.failed,
      usedStub = false;
}

abstract class OcrService {
  String get id;

  /// True when this provider must reach the network. On-device Latin is false.
  bool get requiresNetwork;

  /// Languages this provider is expected to handle. See [OcrRouter].
  Set<String> get expectedLanguageCodes;

  Future<RecognitionResult> recognize({
    required String imagePath,
    required String languageCode,
  });
}

abstract class SttService {
  String get id;

  bool get requiresNetwork;

  Set<String> get expectedLanguageCodes;

  Future<RecognitionResult> transcribe({
    required String audioPath,
    required String languageCode,
  });
}

/// Latin on-device for English and Uzbek. Russian (Cyrillic) goes to the server.
///
/// On-device support is the ML Kit Latin model (`TextRecognitionScript.latin`).
/// It is a script model, not a per-language model. English is the language
/// Google documents well. Uzbek in the official Latin alphabet is routed here
/// because it uses Latin letters, but ML Kit does not list Uzbek, and letters
/// such as oʻ / gʻ may be misread. Uzbek printed in Cyrillic will not be read
/// by this model; choose Russian to send that page to the server.
///
/// The bundled iOS ML Kit product is Latin only. Chinese, Devanagari, Japanese,
/// and Korean exist on the plugin enum and are not linked in this app.
class OcrRouter {
  const OcrRouter({required this.onDevice, required this.server});

  final OcrService onDevice;
  final OcrService server;

  static const onDeviceLanguageCodes = {'en', 'uz'};

  OcrService select(String languageCode) {
    if (onDeviceLanguageCodes.contains(languageCode)) return onDevice;
    return server;
  }
}

class RecognitionConfig {
  const RecognitionConfig({
    required this.apiBase,
    required this.useFakeOcr,
    required this.useFakeStt,
  });

  final String apiBase;
  final bool useFakeOcr;
  final bool useFakeStt;

  factory RecognitionConfig.fromEnvironment() {
    return RecognitionConfig(
      apiBase: const String.fromEnvironment(
        'API_BASE',
        defaultValue: 'http://127.0.0.1:8000',
      ),
      useFakeOcr: const bool.fromEnvironment('USE_FAKE_OCR'),
      useFakeStt: const bool.fromEnvironment('USE_FAKE_STT'),
    );
  }
}
