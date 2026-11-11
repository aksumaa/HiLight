import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class CaptureFileStore {
  Future<String> persistFile({
    required String sourcePath,
    required String folder,
    required String extension,
  });

  Future<String> allocateFile({
    required String folder,
    required String extension,
  });

  Future<void> delete(String? path);
}

class DocumentsCaptureFileStore implements CaptureFileStore {
  DocumentsCaptureFileStore({this.newId = createCaptureId});

  final String Function() newId;

  Future<Directory> _folder(String folder) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'captures', folder));
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<String> persistFile({
    required String sourcePath,
    required String folder,
    required String extension,
  }) async {
    final directory = await _folder(folder);
    final destination = File(p.join(directory.path, '${newId()}.$extension'));
    await File(sourcePath).copy(destination.path);
    return destination.path;
  }

  @override
  Future<String> allocateFile({
    required String folder,
    required String extension,
  }) async {
    final directory = await _folder(folder);
    return p.join(directory.path, '${newId()}.$extension');
  }

  @override
  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

String createCaptureId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int value) => value.toRadixString(16).padLeft(2, '0');
  final text = bytes.map(hex).join();
  return '${text.substring(0, 8)}-${text.substring(8, 12)}-${text.substring(12, 16)}-${text.substring(16, 20)}-${text.substring(20)}';
}
