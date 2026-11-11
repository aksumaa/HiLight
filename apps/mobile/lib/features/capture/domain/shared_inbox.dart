import '../../../data/models/library_item.dart';
import 'capture_event.dart';

class SharedCapture {
  const SharedCapture({required this.id, required this.kind, this.text, this.path});

  final String id;
  final String kind;
  final String? text;
  final String? path;

  factory SharedCapture.fromMap(Map<Object?, Object?> raw) {
    return SharedCapture(
      id: raw['id'] as String? ?? '',
      kind: raw['kind'] as String? ?? 'text',
      text: raw['text'] as String?,
      path: raw['path'] as String?,
    );
  }
}

/// Text and links stay on the device as notes. An image uses the scan path,
/// which already keeps the photo when recognition cannot reach the network.
CaptureEvent? eventForShare(
  SharedCapture share, {
  required String languageCode,
  DateTime? createdAt,
}) {
  if (share.id.isEmpty) return null;
  final created = createdAt ?? DateTime.now().toUtc();
  if (share.kind == 'image') {
    final path = share.path;
    if (path == null || path.isEmpty) return null;
    return CaptureEvent(
      id: share.id,
      type: ItemType.quote,
      source: ItemSource.scan,
      imagePath: path,
      languageCode: languageCode,
      createdAt: created,
    );
  }
  final text = (share.text ?? '').trim();
  if (text.isEmpty) return null;
  return CaptureEvent(
    id: share.id,
    type: ItemType.note,
    source: ItemSource.manual,
    text: text,
    languageCode: languageCode,
    createdAt: created,
  );
}
