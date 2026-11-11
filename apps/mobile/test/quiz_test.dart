import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/features/study/domain/quiz.dart';
import 'package:hilight/features/study/domain/vocab_word.dart';

void main() {
  test('a blank hides the longest word and a correct answer scores good', () {
    final quiz = blankFromSentence('The ephemeral library stayed open.');
    expect(quiz, isNotNull);
    expect(quiz!.prompt, contains('_____'));
    expect(quiz.answer.toLowerCase(), 'ephemeral');
    expect(quizQuality(true), 4);
    expect(quizQuality(false), 1);
  });

  test('choices use the learner\'s other words as distractors', () {
    final now = DateTime.utc(2026);
    VocabWord word(String text) => VocabWord(
      id: text,
      word: text,
      sourceLanguage: 'en',
      targetLanguage: 'en',
      createdAt: now,
      updatedAt: now,
      sourceSentence: 'Remember $text.',
    );
    final quiz = choiceFromVocab([word('habitat'), word('curriculum'), word('automation')]);
    expect(quiz, isNotNull);
    expect(quiz!.options, contains(quiz.answer));
    expect(quiz.options.length, greaterThan(1));
  });

  test('dictation shows the words that were missed', () {
    final diff = diffWords('The old library stayed open', 'The library stayed');
    expect(diff.correct, isFalse);
    expect(diff.missing, contains('old'));
    expect(diff.missing, contains('open'));
  });
}
