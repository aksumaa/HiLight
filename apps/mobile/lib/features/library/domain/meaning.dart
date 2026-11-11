import 'dart:math';

import '../../../data/models/library_item.dart';

/// Local stand-in for a neural embedding. The same 384-d hashing is used by
/// the API when EMBEDDING_PROVIDER=hash, so tests can rank notes without a key.
List<double> meaningVector(String text) {
  final vector = List<double>.filled(384, 0);
  for (final match in RegExp("[A-Za-z']+").allMatches(text.toLowerCase())) {
    final token = match.group(0)!;
    var hash = 0;
    for (final unit in token.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    final index = hash % vector.length;
    vector[index] += (hash & 1) == 0 ? 1 : -1;
  }
  var norm = 0.0;
  for (final value in vector) {
    norm += value * value;
  }
  if (norm == 0) return vector;
  final scale = sqrt(norm);
  return [for (final value in vector) value / scale];
}

double meaningScore(String left, String right) {
  final a = meaningVector(left);
  final b = meaningVector(right);
  var dot = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
  }
  return dot;
}

List<LibraryItem> relatedNotes(List<LibraryItem> items, LibraryItem focus, {int limit = 3}) {
  final ranked = [
    for (final item in items)
      if (item.id != focus.id && item.text.trim().isNotEmpty)
        (item: item, score: meaningScore('${focus.text} ${focus.tag ?? ''}', '${item.text} ${item.tag ?? ''}')),
  ]..sort((a, b) => b.score.compareTo(a.score));
  return [
    for (final row in ranked)
      if (row.score > 0) row.item,
  ].take(limit).toList();
}
