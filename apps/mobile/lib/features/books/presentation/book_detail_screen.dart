import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../library/presentation/library_item_tile.dart';
import '../../study/application/study_providers.dart';
import 'book_study.dart';
import 'reading_panel.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final books = ref.watch(booksProvider);
    final items = ref.watch(libraryItemsProvider);
    return books.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(body: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.homeLoadError))),
      data: (list) {
        final book = list.where((row) => row.id == id).firstOrNull;
        if (book == null) {
          return Scaffold(appBar: AppBar(), body: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.booksEmpty)));
        }
        final highlights = items.value?.where((item) => item.bookId == id).toList() ?? const [];
        return Scaffold(
          appBar: AppBar(title: Text(book.title)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (book.author != null)
                Text(book.author!, style: TextStyle(color: colors.secondary)),
              const SizedBox(height: 16),
              ReadingPanel(book: book, highlights: highlights),
              const SizedBox(height: 12),
              BookStudy(book: book, highlights: highlights),
              const SizedBox(height: 16),
              Text(l10n.bookHighlights, style: TextStyle(color: colors.secondary, fontSize: 13)),
              const SizedBox(height: 12),
              if (highlights.isEmpty)
                Text(l10n.bookNoHighlights, style: TextStyle(color: colors.secondary))
              else
                for (final item in highlights)
                  LibraryItemTile(item: item, onOpen: (item) => context.push('/item/${item.id}')),
            ],
          ),
        );
      },
    );
  }
}
