import '../../../data/models/library_item.dart';
import 'capture_event.dart';
import 'capture_file_store.dart';

abstract class CaptureSource {
  String get id;

  Future<CaptureEvent> capture(CaptureInput input);
}

class PhoneCameraSource implements CaptureSource {
  PhoneCameraSource(
    this._files, {
    this.newId = createCaptureId,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CaptureFileStore _files;
  final String Function() newId;
  final DateTime Function() _clock;

  @override
  String get id => 'phone-camera';

  @override
  Future<CaptureEvent> capture(CaptureInput input) async {
    final sourcePath = input.filePath;
    if (sourcePath == null || sourcePath.isEmpty) {
      throw ArgumentError.value(sourcePath, 'filePath', 'A photo is required.');
    }
    final stored = await _files.persistFile(
      sourcePath: sourcePath,
      folder: 'images',
      extension: 'jpg',
    );
    return CaptureEvent(
      id: newId(),
      type: ItemType.quote,
      source: ItemSource.scan,
      imagePath: stored,
      languageCode: input.languageCode,
      createdAt: _clock(),
    );
  }
}

class PhoneMicSource implements CaptureSource {
  PhoneMicSource({this.newId = createCaptureId, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final String Function() newId;
  final DateTime Function() _clock;

  @override
  String get id => 'phone-mic';

  @override
  Future<CaptureEvent> capture(CaptureInput input) async {
    final audioPath = input.filePath;
    if (audioPath == null || audioPath.isEmpty) {
      throw ArgumentError.value(audioPath, 'filePath', 'Audio is required.');
    }
    return CaptureEvent(
      id: newId(),
      type: ItemType.voice,
      source: ItemSource.voice,
      audioPath: audioPath,
      languageCode: input.languageCode,
      duration: input.duration,
      createdAt: _clock(),
    );
  }
}

class ManualInputSource implements CaptureSource {
  ManualInputSource({this.newId = createCaptureId, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final String Function() newId;
  final DateTime Function() _clock;

  @override
  String get id => 'manual';

  @override
  Future<CaptureEvent> capture(CaptureInput input) async {
    return CaptureEvent(
      id: newId(),
      type: ItemType.note,
      source: ItemSource.manual,
      text: input.text ?? '',
      languageCode: input.languageCode,
      createdAt: _clock(),
    );
  }
}

/// Stand-in for the later Bluetooth pen. It never touches hardware.
class MockDeviceSource implements CaptureSource {
  MockDeviceSource({this.newId = createCaptureId, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final String Function() newId;
  final DateTime Function() _clock;

  @override
  String get id => 'mock-device';

  @override
  Future<CaptureEvent> capture(CaptureInput input) async {
    return CaptureEvent(
      id: newId(),
      type: ItemType.note,
      source: ItemSource.device,
      text: input.text ?? '',
      languageCode: input.languageCode,
      createdAt: _clock(),
    );
  }
}
