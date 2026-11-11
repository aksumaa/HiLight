import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../data/models/library_item.dart';
import '../../books/domain/shelf_book.dart';
import '../../capture/domain/capture_file_store.dart';
import '../../study/application/study_providers.dart';
import '../domain/clipping_parser.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  ImportPreview? _preview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final preview = _preview;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          OutlinedButton(onPressed: _pick, child: Text(l10n.importPick)),
          const SizedBox(height: 16),
          if (preview == null)
            Text(l10n.importEmpty, style: TextStyle(color: colors.secondary))
          else if (preview.highlights.isEmpty)
            Text(l10n.importEmpty, style: TextStyle(color: colors.secondary))
          else ...[
            Text('${l10n.importDuplicates}: ${preview.skippedDuplicates}', style: TextStyle(color: colors.secondary)),
            const SizedBox(height: 12),
            for (final item in preview.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${item.title}: ${item.text}', style: TextStyle(color: colors.text, height: 1.4)),
              ),
            FilledButton(onPressed: _save, child: Text(l10n.importSave)),
          ],
        ],
      ),
    );
  }

  Future<void> _pick() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'csv', 'md'],
    );
    final path = picked.isEmpty ? null : picked.first.path;
    if (path == null) return;
    final source = await File(path).readAsString();
    final lower = path.toLowerCase();
    final parsed = lower.endsWith('.csv')
        ? parseHighlightCsv(source)
        : lower.endsWith('.md')
        ? parseHighlightMarkdown(source)
        : parseKindleClippings(source);
    final items = ref.read(libraryItemsProvider).value ?? const <LibraryItem>[];
    final books = ref.read(booksProvider).value ?? const [];
    final existing = {
      for (final item in items)
        if (item.bookId != null)
          highlightKey(
            books.where((book) => book.id == item.bookId).firstOrNull?.title ?? '',
            item.text,
          )
        else
          highlightKey('', item.text),
    };
    setState(() => _preview = dropDuplicates(parsed, existingKeys: existing));
  }

  Future<void> _save() async {
    final preview = _preview;
    if (preview == null) return;
    final books = ref.read(booksProvider).value ?? const [];
    final now = DateTime.now().toUtc();
    final ids = <String, String>{};
    for (final book in books) {
      ids[book.title.toLowerCase()] = book.id;
    }
    for (final highlight in preview.highlights) {
      var bookId = ids[highlight.title.toLowerCase()];
      if (bookId == null) {
        bookId = createCaptureId();
        ids[highlight.title.toLowerCase()] = bookId;
        await ref.read(bookRepositoryProvider).add(
          ShelfBook(
            id: bookId,
            title: highlight.title,
            author: highlight.author,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      await ref.read(itemRepositoryProvider).add(
        LibraryItem(
          id: createCaptureId(),
          type: ItemType.quote,
          source: ItemSource.manual,
          text: highlight.text,
          page: highlight.page,
          bookId: bookId,
          languageCode: 'en',
          createdAt: now,
          updatedAt: now,
          recognitionStatus: RecognitionStatus.recognized,
          dirty: true,
        ),
      );
    }
    if (mounted) context.pop();
  }
}
