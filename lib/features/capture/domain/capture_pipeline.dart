import '../../../data/models/library_item.dart';
import '../../../data/repositories/item_repository.dart';
import 'capture_event.dart';
import 'capture_file_store.dart';
import 'recognition.dart';
import 'recognition_network.dart';

class CapturePipeline {
  CapturePipeline({
    required this.ocr,
    required this.stt,
    required this.network,
    required this.repository,
    required this.files,
  });

  final OcrRouter ocr;
  final SttService stt;
  final RecognitionNetwork network;
  final ItemRepository repository;
  final CaptureFileStore files;

  /// Turns a [CaptureEvent] into text, or stores the raw file when the
  /// server cannot be reached.
  Future<ProcessedCapture> process(
    CaptureEvent event, {
    bool storePending = true,
  }) async {
    if (event.source == ItemSource.manual || event.source == ItemSource.device) {
      return ProcessedCapture(
        event: event,
        outcome: CaptureOutcome.recognized,
        text: event.text ?? '',
      );
    }
    if (event.exceedsRecordingLimit) {
      return ProcessedCapture(
        event: event,
        outcome: CaptureOutcome.tooLong,
        text: '',
      );
    }
    if (event.source == ItemSource.scan) {
      return _recognizeImage(event, storePending: storePending);
    }
    return _transcribe(event, storePending: storePending);
  }

  Future<LibraryItem> save(
    ProcessedCapture processed, {
    required String text,
    String? tag,
    int? page,
    String? languageCode,
  }) async {
    final item = LibraryItem(
      id: processed.saved?.id ?? processed.event.id,
      type: processed.event.type,
      source: processed.event.source,
      text: text.trim(),
      tag: _blankToNull(tag),
      page: page,
      audioPath: processed.event.audioPath,
      imagePath: processed.event.imagePath,
      languageCode: languageCode ?? processed.event.languageCode,
      createdAt: processed.saved?.createdAt ?? processed.event.createdAt,
      updatedAt: DateTime.now().toUtc(),
      dirty: true,
      recognitionStatus: statusForSave(processed.outcome, text),
    );
    if (processed.saved == null) {
      return repository.add(item);
    }
    return repository.update(item);
  }

  Future<void> discard(ProcessedCapture processed) async {
    final id = processed.saved?.id;
    if (id != null) await repository.delete(id);
    await files.delete(processed.event.imagePath);
    await files.delete(processed.event.audioPath);
  }

  Future<ProcessedCapture> _recognizeImage(
    CaptureEvent event, {
    required bool storePending,
  }) async {
    final path = event.imagePath;
    if (path == null || path.isEmpty) {
      return ProcessedCapture(
        event: event,
        outcome: CaptureOutcome.failed,
        text: '',
      );
    }
    final service = ocr.select(event.languageCode);
    if (service.requiresNetwork && !await network.isOnline) {
      return _pending(event, storePending: storePending);
    }
    try {
      final result = await service.recognize(
        imagePath: path,
        languageCode: event.languageCode,
      );
      if (result.outcome == CaptureOutcome.pendingOffline) {
        return _pending(event, storePending: storePending);
      }
      return ProcessedCapture(
        event: event,
        outcome: result.outcome,
        text: result.text,
        usedStub: result.usedStub,
      );
    } on Exception {
      return ProcessedCapture(
        event: event,
        outcome: CaptureOutcome.failed,
        text: '',
      );
    }
  }

  Future<ProcessedCapture> _transcribe(
    CaptureEvent event, {
    required bool storePending,
  }) async {
    final path = event.audioPath;
    if (path == null || path.isEmpty) {
      return ProcessedCapture(
        event: event,
        outcome: CaptureOutcome.failed,
        text: '',
      );
    }
    if (stt.requiresNetwork && !await network.isOnline) {
      return _pending(event, storePending: storePending);
    }
    try {
      final result = await stt.transcribe(
        audioPath: path,
        languageCode: event.languageCode,
      );
      if (result.outcome == CaptureOutcome.pendingOffline) {
        return _pending(event, storePending: storePending);
      }
      return ProcessedCapture(
        event: event,
        outcome: result.outcome,
        text: result.text,
        usedStub: result.usedStub,
      );
    } on Exception {
      return ProcessedCapture(
        event: event,
        outcome: CaptureOutcome.failed,
        text: '',
      );
    }
  }

  Future<ProcessedCapture> _pending(
    CaptureEvent event, {
    required bool storePending,
  }) async {
    LibraryItem? saved;
    if (storePending) {
      saved = await repository.add(
        LibraryItem(
          id: event.id,
          type: event.type,
          source: event.source,
          text: '',
          imagePath: event.imagePath,
          audioPath: event.audioPath,
          languageCode: event.languageCode,
          createdAt: event.createdAt,
          updatedAt: event.createdAt.toUtc(),
          dirty: true,
          recognitionStatus: RecognitionStatus.pending,
        ),
      );
    }
    return ProcessedCapture(
      event: event,
      outcome: CaptureOutcome.pendingOffline,
      text: '',
      saved: saved,
    );
  }
}

RecognitionStatus statusForSave(CaptureOutcome outcome, String text) {
  if (text.trim().isNotEmpty) return RecognitionStatus.recognized;
  if (outcome == CaptureOutcome.pendingOffline ||
      outcome == CaptureOutcome.tooLong) {
    return RecognitionStatus.pending;
  }
  return RecognitionStatus.empty;
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
