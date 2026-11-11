class ShelfBook {
  const ShelfBook({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.coverUrl,
    this.totalPages,
    this.isbn,
    this.deletedAt,
    this.dirty = false,
  });

  final String id;
  final String title;
  final String? author;
  final String? coverUrl;
  final int? totalPages;
  final String? isbn;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool dirty;

  ShelfBook copyWith({
    String? title,
    String? author,
    String? coverUrl,
    int? totalPages,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? dirty,
    bool clearAuthor = false,
    bool clearCover = false,
  }) {
    return ShelfBook(
      id: id,
      title: title ?? this.title,
      author: clearAuthor ? null : author ?? this.author,
      coverUrl: clearCover ? null : coverUrl ?? this.coverUrl,
      totalPages: totalPages ?? this.totalPages,
      isbn: isbn,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
    );
  }
}

class BookDraft {
  const BookDraft({
    required this.title,
    this.author,
    this.coverUrl,
    this.totalPages,
    this.isbn,
  });

  final String title;
  final String? author;
  final String? coverUrl;
  final int? totalPages;
  final String? isbn;
}
