enum ItemType { quote, voice, note, ai }

enum ItemSource { scan, voice, manual, device }

enum RecognitionStatus { recognized, pending, empty }

/// A library row. The UI and the capture pipeline use this type.
/// Drift rows stay inside the database implementation.
class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.type,
    required this.source,
    required this.text,
    required this.languageCode,
    required this.createdAt,
    required this.recognitionStatus,
    this.updatedAt,
    this.deletedAt,
    this.dirty = false,
    this.tag,
    this.page,
    this.audioPath,
    this.imagePath,
  });

  final String id;
  final ItemType type;
  final ItemSource source;
  final String text;
  final String? tag;
  final int? page;
  final String? audioPath;
  final String? imagePath;
  final String languageCode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool dirty;
  final RecognitionStatus recognitionStatus;

  DateTime get modifiedAt => updatedAt ?? createdAt;

  LibraryItem copyWith({
    String? text,
    String? tag,
    int? page,
    String? languageCode,
    RecognitionStatus? recognitionStatus,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? dirty,
    bool clearTag = false,
    bool clearPage = false,
  }) {
    return LibraryItem(
      id: id,
      type: type,
      source: source,
      text: text ?? this.text,
      tag: clearTag ? null : tag ?? this.tag,
      page: clearPage ? null : page ?? this.page,
      audioPath: audioPath,
      imagePath: imagePath,
      languageCode: languageCode ?? this.languageCode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      recognitionStatus: recognitionStatus ?? this.recognitionStatus,
    );
  }
}
