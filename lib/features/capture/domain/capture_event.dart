import '../../../data/models/library_item.dart';

/// Ten minutes. Longer clips are kept on disk and not uploaded.
const Duration kMaxRecording = Duration(minutes: 10);

class CaptureInput {
  const CaptureInput({
    required this.languageCode,
    this.filePath,
    this.text,
    this.duration,
  });

  final String languageCode;
  final String? filePath;
  final String? text;
  final Duration? duration;
}

class CaptureEvent {
  const CaptureEvent({
    required this.id,
    required this.type,
    required this.source,
    required this.languageCode,
    required this.createdAt,
    this.text,
    this.imagePath,
    this.audioPath,
    this.duration,
  });

  final String id;
  final ItemType type;
  final ItemSource source;
  final String languageCode;
  final DateTime createdAt;
  final String? text;
  final String? imagePath;
  final String? audioPath;
  final Duration? duration;

  bool get exceedsRecordingLimit =>
      duration != null && duration! > kMaxRecording;

  CaptureEvent copyWith({String? languageCode}) {
    return CaptureEvent(
      id: id,
      type: type,
      source: source,
      languageCode: languageCode ?? this.languageCode,
      createdAt: createdAt,
      text: text,
      imagePath: imagePath,
      audioPath: audioPath,
      duration: duration,
    );
  }
}

enum CaptureOutcome { recognized, pendingOffline, empty, tooLong, failed }

class ProcessedCapture {
  const ProcessedCapture({
    required this.event,
    required this.outcome,
    required this.text,
    this.usedStub = false,
    this.saved,
  });

  final CaptureEvent event;
  final CaptureOutcome outcome;
  final String text;
  final bool usedStub;
  final LibraryItem? saved;

  ProcessedCapture copyWith({LibraryItem? saved, String? text}) {
    return ProcessedCapture(
      event: event,
      outcome: outcome,
      text: text ?? this.text,
      usedStub: usedStub,
      saved: saved ?? this.saved,
    );
  }
}

/// Camera plugin codes that mean the person denied access.
CapturePermission? permissionFromCameraCode(String code) {
  switch (code) {
    case 'CameraAccessDenied':
    case 'CameraAccessDeniedWithoutPrompt':
      return CapturePermission.camera;
    default:
      return null;
  }
}

enum CapturePermission { camera, microphone }
