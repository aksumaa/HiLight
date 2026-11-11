import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/features/study/domain/word_suggestions.dart';

void main() {
  test('suggestions skip common words, saved words, and stop at five', () {
    const text = 'The ephemeral palimpsest beside the house was luminous, ephemeral, and already saved.';
    final words = uncommonWords(text, {'saved'});
    expect(words, ['ephemeral', 'palimpsest', 'beside', 'luminous']);
    expect(words, isNot(contains('house')));
    expect(words, isNot(contains('already')));
  });
}
