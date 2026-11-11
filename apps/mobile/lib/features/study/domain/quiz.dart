import 'vocab_word.dart';

class BlankQuiz {
  const BlankQuiz({required this.prompt, required this.answer, required this.sentence});

  final String prompt;
  final String answer;
  final String sentence;
}

class ChoiceQuiz {
  const ChoiceQuiz({required this.prompt, required this.answer, required this.options});

  final String prompt;
  final String answer;
  final List<String> options;
}

class WordDiff {
  const WordDiff({required this.missing, required this.extra, required this.correct});

  final List<String> missing;
  final List<String> extra;
  final bool correct;
}

BlankQuiz? blankFromSentence(String sentence) {
  final match = RegExp("[A-Za-z][A-Za-z'-]{4,}").allMatches(sentence).fold<RegExpMatch?>(
    null,
    (best, current) => best == null || current.group(0)!.length > best.group(0)!.length ? current : best,
  );
  if (match == null) return null;
  final word = match.group(0)!;
  return BlankQuiz(
    prompt: sentence.replaceFirst(word, '_____'),
    answer: word,
    sentence: sentence,
  );
}

ChoiceQuiz? choiceFromVocab(List<VocabWord> words, {int variant = 0}) {
  final usable = [for (final word in words) if (word.word.trim().isNotEmpty) word];
  if (usable.length < 2) return null;
  final answer = usable[variant.abs() % usable.length];
  final distractors = [
    for (final word in usable)
      if (word.word.toLowerCase() != answer.word.toLowerCase()) word.word,
  ].take(3);
  final options = [answer.word, ...distractors]..sort();
  final prompt = answer.sourceSentence.trim().isEmpty ? answer.word : answer.sourceSentence;
  return ChoiceQuiz(prompt: prompt, answer: answer.word, options: options);
}

WordDiff diffWords(String expected, String typed) {
  final left = _words(expected);
  final right = _words(typed);
  final missing = [
    for (final word in left)
      if (!right.contains(word)) word,
  ];
  final extra = [
    for (final word in right)
      if (!left.contains(word)) word,
  ];
  return WordDiff(missing: missing, extra: extra, correct: missing.isEmpty && extra.isEmpty && left.isNotEmpty);
}

List<String> _words(String text) {
  return [
    for (final match in RegExp("[A-Za-z']+").allMatches(text.toLowerCase())) match.group(0)!,
  ];
}

int quizQuality(bool correct) => correct ? 4 : 1;
