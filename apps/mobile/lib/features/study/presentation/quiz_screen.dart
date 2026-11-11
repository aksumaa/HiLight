import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../study/application/study_providers.dart';
import '../domain/quiz.dart';

enum _QuizKind { blank, choice, dictation }

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  _QuizKind _kind = _QuizKind.blank;
  final _answer = TextEditingController();
  final _tts = FlutterTts();
  String? _feedback;
  var _variant = 0;

  @override
  void dispose() {
    _answer.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final items = ref.watch(libraryItemsProvider).value ?? const [];
    final words = ref.watch(vocabProvider).value ?? const [];
    final sentence = items.where((item) => item.text.trim().isNotEmpty).map((item) => item.text).firstOrNull;
    final blank = sentence == null ? null : blankFromSentence(sentence);
    final choice = choiceFromVocab(words, variant: _variant);
    final dictation = sentence;
    final empty = switch (_kind) {
      _QuizKind.blank => blank == null,
      _QuizKind.choice => choice == null,
      _QuizKind.dictation => dictation == null,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: Text(l10n.quizBlank), selected: _kind == _QuizKind.blank, onSelected: (_) => _switch(_QuizKind.blank)),
              ChoiceChip(label: Text(l10n.quizChoice), selected: _kind == _QuizKind.choice, onSelected: (_) => _switch(_QuizKind.choice)),
              ChoiceChip(label: Text(l10n.quizDictation), selected: _kind == _QuizKind.dictation, onSelected: (_) => _switch(_QuizKind.dictation)),
            ],
          ),
          const SizedBox(height: 16),
          if (empty)
            Text(l10n.quizEmpty, style: TextStyle(color: colors.secondary, height: 1.4))
          else ...[
            Text(
              switch (_kind) {
                _QuizKind.blank => blank!.prompt,
                _QuizKind.choice => choice!.prompt,
                _QuizKind.dictation => l10n.quizSpeak,
              },
              style: TextStyle(color: colors.text, fontSize: 18, height: 1.4),
            ),
            if (_kind == _QuizKind.dictation)
              IconButton(
                tooltip: l10n.quizSpeak,
                onPressed: () => _tts.speak(dictation!),
                icon: Icon(Icons.volume_up_outlined, color: colors.primary),
              ),
            if (_kind == _QuizKind.choice)
              Wrap(
                spacing: 8,
                children: [
                  for (final option in choice!.options)
                    ChoiceChip(
                      label: Text(option),
                      selected: _answer.text == option,
                      onSelected: (_) => setState(() => _answer.text = option),
                    ),
                ],
              )
            else
              TextField(controller: _answer, decoration: InputDecoration(hintText: l10n.quizCheck)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _check(
                prompt: switch (_kind) {
                  _QuizKind.blank => blank!.prompt,
                  _QuizKind.choice => choice!.prompt,
                  _QuizKind.dictation => dictation!,
                },
                expected: switch (_kind) {
                  _QuizKind.blank => blank!.answer,
                  _QuizKind.choice => choice!.answer,
                  _QuizKind.dictation => dictation!,
                },
              ),
              child: Text(l10n.quizCheck),
            ),
            if (_feedback != null) ...[
              const SizedBox(height: 12),
              Text(_feedback!, style: TextStyle(color: colors.secondary, height: 1.4)),
            ],
          ],
        ],
      ),
    );
  }

  void _switch(_QuizKind kind) {
    setState(() {
      _kind = kind;
      _answer.clear();
      _feedback = null;
    });
  }

  Future<void> _check({required String prompt, required String expected}) async {
    final l10n = AppLocalizations.of(context);
    final typed = _answer.text.trim();
    final correct = _kind == _QuizKind.dictation
        ? diffWords(expected, typed).correct
        : typed.toLowerCase() == expected.toLowerCase();
    final diff = _kind == _QuizKind.dictation ? diffWords(expected, typed) : null;
    await ref.read(studyRepositoryProvider).recordQuiz(
      prompt: prompt,
      answer: expected,
      quality: quizQuality(correct),
    );
    if (!mounted) return;
    setState(() {
      _variant += 1;
      _feedback = correct
          ? l10n.quizCorrect
          : '${l10n.quizAgain}${diff == null ? '' : ' ${diff.missing.join(', ')}'}';
      _answer.clear();
    });
  }
}
