import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../capture/domain/capture_file_store.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../profile/application/settings_controller.dart';
import '../application/study_providers.dart';
import '../domain/vocab_word.dart';
import '../domain/word_lookup_service.dart';

Future<void> showWordSheet(
  BuildContext context,
  WidgetRef ref, {
  required String word,
  required String sentence,
  String? itemId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _WordSheet(word: word, sentence: sentence, itemId: itemId),
  );
}

class _WordSheet extends ConsumerStatefulWidget {
  const _WordSheet({required this.word, required this.sentence, this.itemId});

  final String word;
  final String sentence;
  final String? itemId;

  @override
  ConsumerState<_WordSheet> createState() => _WordSheetState();
}

class _WordSheetState extends ConsumerState<_WordSheet> {
  late String _target;
  LookupResult? _result;
  var _offline = false;
  var _loading = true;
  final _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _target = 'en';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _target = ref.read(settingsProvider).localeCode;
      _load();
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _offline = false;
    });
    try {
      final result = await ref.read(wordLookupProvider).lookup(
        word: widget.word,
        sourceLanguage: 'en',
        targetLanguage: _target,
        sentence: widget.sentence,
      );
      if (mounted) setState(() => _result = result);
    } on LookupException {
      if (mounted) setState(() => _offline = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final result = _result;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.word, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: colors.text)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final code in ['en', 'ru', 'uz'])
                ChoiceChip(
                  label: Text(code),
                  selected: _target == code,
                  onSelected: (_) {
                    setState(() => _target = code);
                    _load();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_offline) Text(l10n.lookupOffline, style: TextStyle(color: colors.secondary)),
          if (result != null) ...[
            Text(result.partOfSpeech, style: TextStyle(color: colors.secondary, fontSize: 13)),
            const SizedBox(height: 8),
            Text(result.translation, style: TextStyle(color: colors.text, fontSize: 16)),
            const SizedBox(height: 8),
            Text(result.definition, style: TextStyle(color: colors.secondary, height: 1.4)),
            const SizedBox(height: 8),
            Text(result.example, style: TextStyle(color: colors.text, height: 1.4)),
            const SizedBox(height: 16),
            Row(
              children: [
                Semantics(
                  button: true,
                  label: l10n.lookupSpeak,
                  child: IconButton(
                    onPressed: () => _tts.speak(widget.word),
                    icon: Icon(Icons.volume_up_outlined, color: colors.primary),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/practice', extra: widget.word),
                  child: Text(l10n.pronounceTitle),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    final now = DateTime.now().toUtc();
                    await ref.read(studyRepositoryProvider).saveWord(
                      VocabWord(
                        id: createCaptureId(),
                        word: widget.word.toLowerCase(),
                        sourceLanguage: 'en',
                        targetLanguage: _target,
                        translation: result.translation,
                        definition: result.definition,
                        example: result.example,
                        partOfSpeech: result.partOfSpeech,
                        sourceSentence: widget.sentence,
                        sourceItemId: widget.itemId,
                        createdAt: now,
                        updatedAt: now,
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(l10n.lookupSave),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
