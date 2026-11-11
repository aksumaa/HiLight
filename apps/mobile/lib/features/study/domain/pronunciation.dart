/// 0–100. This is letter overlap after speech-to-text, not a phonetic grade.
int pronunciationScore(String target, String heard) {
  final left = _letters(target);
  final right = _letters(heard);
  if (left.isEmpty || right.isEmpty) return 0;
  final distance = _distance(left, right);
  final longest = left.length > right.length ? left.length : right.length;
  final score = ((1 - distance / longest) * 100).round();
  if (score < 0) return 0;
  if (score > 100) return 100;
  return score;
}

String _letters(String value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

int _distance(String left, String right) {
  final rows = List.generate(left.length + 1, (index) => index);
  for (var j = 1; j <= right.length; j++) {
    var previous = rows[0];
    rows[0] = j;
    for (var i = 1; i <= left.length; i++) {
      final current = rows[i];
      final cost = left[i - 1] == right[j - 1] ? 0 : 1;
      final insert = rows[i] + 1;
      final delete = rows[i - 1] + 1;
      final replace = previous + cost;
      rows[i] = insert < delete ? (insert < replace ? insert : replace) : (delete < replace ? delete : replace);
      previous = current;
    }
  }
  return rows[left.length];
}
