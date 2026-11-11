import '../../../data/models/library_item.dart';
import 'meaning.dart';

enum LibraryFilter { all, quote, voice, note, ai }

List<LibraryItem> filterLibrary(
  List<LibraryItem> items, {
  required LibraryFilter filter,
  required String query,
  bool meaning = false,
}) {
  final needle = query.trim().toLowerCase();
  final typed = [
    for (final item in items)
      if (_typeMatches(item, filter)) item,
  ];
  if (needle.isEmpty) return typed;
  if (!meaning) {
    return [
      for (final item in typed)
        if (_queryMatches(item, needle)) item,
    ];
  }
  final ranked = [
    for (final item in typed) (item: item, score: meaningScore(needle, '${item.text} ${item.tag ?? ''}')),
  ]..sort((a, b) => b.score.compareTo(a.score));
  return [for (final row in ranked) if (row.score > 0) row.item];
}

bool _typeMatches(LibraryItem item, LibraryFilter filter) {
  return switch (filter) {
    LibraryFilter.all => true,
    LibraryFilter.quote => item.type == ItemType.quote,
    LibraryFilter.voice => item.type == ItemType.voice,
    LibraryFilter.note => item.type == ItemType.note,
    LibraryFilter.ai => item.type == ItemType.ai,
  };
}

bool _queryMatches(LibraryItem item, String needle) {
  if (needle.isEmpty) return true;
  final tag = item.tag ?? '';
  return item.text.toLowerCase().contains(needle) || tag.toLowerCase().contains(needle);
}

class HomeFeed {
  const HomeFeed({required this.review, required this.recent});

  final List<LibraryItem> review;
  final List<LibraryItem> recent;

  factory HomeFeed.from(List<LibraryItem> items) {
    final oldest = [...items]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final review = oldest.take(3).toList();
    final reviewIds = review.map((item) => item.id).toSet();
    return HomeFeed(
      review: review,
      recent: [
        for (final item in items)
          if (!reviewIds.contains(item.id)) item,
      ],
    );
  }
}
