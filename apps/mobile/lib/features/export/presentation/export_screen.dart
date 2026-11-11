import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../study/application/study_providers.dart';
import '../domain/exporters.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final items = ref.watch(libraryItemsProvider).value ?? const [];
    final books = ref.watch(booksProvider).value ?? const [];
    final words = ref.watch(vocabProvider).value ?? const [];
    final grouped = groupHighlights(books, items);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (grouped.isEmpty && words.isEmpty)
            Text(l10n.exportEmpty, style: TextStyle(color: colors.secondary, height: 1.4))
          else ...[
            _ExportButton(
              title: l10n.exportObsidian,
              body: l10n.exportObsidianBody,
              onPressed: grouped.isEmpty ? null : () => _shareFolder(obsidianFiles(grouped)),
            ),
            _ExportButton(
              title: l10n.exportNotion,
              body: l10n.exportNotionBody,
              onPressed: grouped.isEmpty ? null : () => _shareText('hilight-notion.md', notionMarkdown(grouped)),
            ),
            _ExportButton(
              title: l10n.exportAnki,
              body: l10n.exportAnkiBody,
              onPressed: words.isEmpty ? null : () => _shareText('hilight-anki.csv', ankiCsv(words)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _shareText(String name, String contents) async {
    final file = File('${(await getTemporaryDirectory()).path}/$name');
    await file.writeAsString(contents);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<void> _shareFolder(Map<String, String> files) async {
    final directory = Directory('${(await getTemporaryDirectory()).path}/hilight-obsidian');
    if (directory.existsSync()) directory.deleteSync(recursive: true);
    directory.createSync();
    final shared = <XFile>[];
    for (final entry in files.entries) {
      final file = File('${directory.path}/${entry.key}');
      await file.writeAsString(entry.value);
      shared.add(XFile(file.path));
    }
    await SharePlus.instance.share(ShareParams(files: shared));
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.title, required this.body, required this.onPressed});

  final String title;
  final String body;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: colors.surface(),
        child: ListTile(
          title: Text(title),
          subtitle: Text(body, style: TextStyle(color: colors.secondary)),
          onTap: onPressed,
        ),
      ),
    );
  }
}
