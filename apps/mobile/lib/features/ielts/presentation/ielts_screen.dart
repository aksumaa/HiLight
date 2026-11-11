import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../data/models/library_item.dart';
import '../../ai/application/tutor_provider.dart';
import '../../capture/domain/capture_file_store.dart';
import '../../profile/application/settings_controller.dart';
import '../../study/application/study_providers.dart';
import '../../study/domain/vocab_word.dart';
import '../domain/starter_content.dart';

class IeltsScreen extends ConsumerStatefulWidget {
  const IeltsScreen({super.key});

  @override
  ConsumerState<IeltsScreen> createState() => _IeltsScreenState();
}

class _IeltsScreenState extends ConsumerState<IeltsScreen> {
  var _shelf = IeltsShelf.vocab;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _seed());
  }

  Future<void> _seed() async {
    if (_seeded) return;
    _seeded = true;
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool('ielts_seeded') == true) return;
    final now = DateTime.now().toUtc();
    for (final entry in ieltsStarter) {
      await ref.read(itemRepositoryProvider).add(
        LibraryItem(
          id: createCaptureId(),
          type: ItemType.note,
          source: ItemSource.manual,
          text: entry.text,
          tag: entry.tag,
          note: entry.note,
          chapter: entry.task?.name,
          languageCode: 'en',
          createdAt: now,
          updatedAt: now,
          recognitionStatus: RecognitionStatus.recognized,
          dirty: true,
        ),
      );
      if (entry.word != null) {
        await ref.read(studyRepositoryProvider).saveWord(
          VocabWord(
            id: createCaptureId(),
            word: entry.word!,
            sourceLanguage: 'en',
            targetLanguage: ref.read(settingsProvider).localeCode,
            translation: entry.translation ?? '',
            sourceSentence: entry.note ?? entry.text,
            tags: entry.topic.name,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
    await prefs.setBool('ielts_seeded', true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final items = ref.watch(libraryItemsProvider).value ?? const <LibraryItem>[];
    final prefix = 'ielts/${_shelf.name}/';
    final shown = [for (final item in items) if ((item.tag ?? '').startsWith(prefix)) item];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ieltsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final shelf in IeltsShelf.values)
                ChoiceChip(
                  label: Text(_shelfLabel(l10n, shelf)),
                  selected: _shelf == shelf,
                  onSelected: (_) => setState(() => _shelf = shelf),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => context.push('/quiz'), child: Text(l10n.quizTitle)),
          ),
          if (shown.isEmpty)
            Text(l10n.ieltsEmpty, style: TextStyle(color: colors.secondary, height: 1.4))
          else
            for (final item in shown) _Entry(item: item),
          const SizedBox(height: 20),
          Text(l10n.ieltsOfficial, style: TextStyle(color: colors.text, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(l10n.ieltsOfficialBody, style: TextStyle(color: colors.secondary, height: 1.4)),
          for (final link in ieltsOfficialLinks)
            TextButton(
              onPressed: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
              child: Align(alignment: Alignment.centerLeft, child: Text(link)),
            ),
        ],
      ),
    );
  }

  String _shelfLabel(AppLocalizations l10n, IeltsShelf shelf) {
    return switch (shelf) {
      IeltsShelf.vocab => l10n.ieltsVocab,
      IeltsShelf.listening => l10n.ieltsListening,
      IeltsShelf.reading => l10n.ieltsReading,
      IeltsShelf.writing => l10n.ieltsWriting,
    };
  }
}

class _Entry extends ConsumerWidget {
  const _Entry({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final writing = (item.tag ?? '').contains('/writing/');
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: colors.surface(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_topic(l10n, item.tag ?? ''), style: TextStyle(color: colors.secondary, fontSize: 13)),
              if (item.chapter != null)
                Text(item.chapter == 'task1' ? l10n.ieltsTask1 : l10n.ieltsTask2, style: TextStyle(color: colors.secondary, fontSize: 13)),
              if (writing && item.note != null) ...[
                const SizedBox(height: 8),
                Text('${l10n.ieltsBefore}: ${item.note}', style: TextStyle(color: colors.secondary)),
              ],
              const SizedBox(height: 8),
              Text(item.text, style: TextStyle(color: colors.text, height: 1.4)),
              if (!writing && item.note != null) ...[
                const SizedBox(height: 8),
                Text(item.note!, style: TextStyle(color: colors.secondary, height: 1.4)),
              ],
              if (writing)
                TextButton(
                  onPressed: () => _upgrade(context, ref, item.text, item.tag ?? ''),
                  child: Text(l10n.ieltsUpgrade),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _topic(AppLocalizations l10n, String tag) {
    if (tag.contains('education')) return l10n.topicEducation;
    if (tag.contains('environment')) return l10n.topicEnvironment;
    if (tag.contains('technology')) return l10n.topicTechnology;
    if (tag.contains('health')) return l10n.topicHealth;
    if (tag.contains('work')) return l10n.topicWork;
    return l10n.topicSociety;
  }

  Future<void> _upgrade(BuildContext context, WidgetRef ref, String sentence, String tag) async {
    final l10n = AppLocalizations.of(context);
    final topic = tag.split('/').last;
    final reply = await ref.read(tutorProvider).rewrite(sentence: sentence, task: 'task2', topic: topic);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final colors = context.hilight;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(reply.limitReached ? l10n.aiLimit : l10n.ieltsDisclaimer, style: TextStyle(color: colors.secondary, height: 1.4)),
              if (reply.offline) Text(l10n.aiOffline, style: TextStyle(color: colors.secondary)),
              for (final version in reply.versions) ...[
                const SizedBox(height: 12),
                Text(version.text, style: TextStyle(color: colors.text, height: 1.4)),
                Text(version.explanation, style: TextStyle(color: colors.secondary, fontSize: 13)),
              ],
            ],
          ),
        );
      },
    );
  }
}
