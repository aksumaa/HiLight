import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../application/study_providers.dart';
import '../domain/vocab_word.dart';

class VocabScreen extends ConsumerStatefulWidget {
  const VocabScreen({super.key});

  @override
  ConsumerState<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends ConsumerState<VocabScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final words = ref.watch(vocabProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.vocabTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: l10n.vocabSearch),
            ),
          ),
          Expanded(
            child: words.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Padding(padding: const EdgeInsets.all(24), child: Text(l10n.homeLoadError)),
              data: (list) {
                final needle = _search.text.trim().toLowerCase();
                final shown = [
                  for (final word in list)
                    if (needle.isEmpty ||
                        word.word.contains(needle) ||
                        word.tags.toLowerCase().contains(needle))
                      word,
                ];
                if (shown.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.vocabEmpty, style: TextStyle(color: colors.secondary, height: 1.4)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    final word = shown[index];
                    return Semantics(
                      label: word.word,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(word.word),
                        subtitle: Text('${word.translation} · ${_mastery(l10n, word.mastery)}'),
                        trailing: IconButton(
                          tooltip: l10n.itemDelete,
                          onPressed: () => _delete(word),
                          icon: Icon(Icons.delete_outline, color: colors.secondary),
                        ),
                        onTap: () {
                          final next = switch (word.mastery) {
                            WordMastery.newWord => WordMastery.learning,
                            WordMastery.learning => WordMastery.known,
                            WordMastery.known => WordMastery.newWord,
                          };
                          ref.read(studyRepositoryProvider).setMastery(word.id, next);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _mastery(AppLocalizations l10n, WordMastery mastery) {
    return switch (mastery) {
      WordMastery.newWord => l10n.masteryNew,
      WordMastery.learning => l10n.masteryLearning,
      WordMastery.known => l10n.masteryKnown,
    };
  }

  Future<void> _delete(VocabWord word) async {
    final l10n = AppLocalizations.of(context);
    final removed = await ref.read(studyRepositoryProvider).softDelete(word.id);
    if (!mounted || removed == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.vocabDeleted),
        action: SnackBarAction(
          label: l10n.vocabUndo,
          onPressed: () => ref.read(studyRepositoryProvider).restore(removed),
        ),
      ),
    );
  }
}
