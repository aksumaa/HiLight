import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../data/models/library_item.dart';
import '../../study/application/study_providers.dart';
import '../domain/shelf_book.dart';

class BooksView extends ConsumerWidget {
  const BooksView({required this.items, super.key});

  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final books = ref.watch(booksProvider);
    return books.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Padding(padding: const EdgeInsets.all(24), child: Text(l10n.homeLoadError)),
      data: (list) {
        if (list.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              Text(l10n.booksEmpty, style: TextStyle(color: colors.secondary, height: 1.4)),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.push('/books/add'), child: Text(l10n.addBook)),
            ],
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemCount: list.length + 1,
          itemBuilder: (context, index) {
            if (index == list.length) {
              return OutlinedButton(onPressed: () => context.push('/books/add'), child: Text(l10n.addBook));
            }
            final book = list[index];
            final progress = _progress(book, items);
            return Semantics(
              button: true,
              label: book.title,
              child: InkWell(
                onTap: () => context.push('/books/${book.id}'),
                child: DecoratedBox(
                  decoration: colors.surface(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: book.coverUrl == null
                              ? Text(
                                  book.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w500),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    book.coverUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, _, _) => Text(
                                      book.title,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: colors.text, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                        ),
                        if (book.author != null)
                          Text(book.author!, maxLines: 1, style: TextStyle(color: colors.secondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 2,
                          color: colors.primary,
                          backgroundColor: colors.hairline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _progress(ShelfBook book, List<LibraryItem> items) {
    final pages = book.totalPages;
    if (pages == null || pages <= 0) return 0;
    final read = items.where((item) => item.bookId == book.id && item.page != null).map((item) => item.page!);
    if (read.isEmpty) return 0;
    return min(1, read.reduce(max) / pages);
  }
}
