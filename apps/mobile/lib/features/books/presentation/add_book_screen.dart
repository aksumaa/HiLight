import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../capture/domain/capture_file_store.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../study/application/study_providers.dart';
import '../domain/shelf_book.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _query = TextEditingController();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  var _results = const <BookDraft>[];
  var _searching = false;

  @override
  void dispose() {
    _query.dispose();
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addBook)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            controller: _query,
            decoration: InputDecoration(hintText: l10n.searchBooks),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _searching ? null : _search, child: Text(l10n.searchBooks)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final isbn = await context.push<String>('/books/scan');
              if (isbn == null || !mounted) return;
              final draft = await ref.read(bookMetadataProvider).byIsbn(isbn);
              if (draft == null) {
                _title.text = isbn;
                return;
              }
              await _save(draft);
            },
            child: Text(l10n.scanIsbn),
          ),
          for (final draft in _results)
            ListTile(
              title: Text(draft.title),
              subtitle: Text(draft.author ?? ''),
              onTap: () => _save(draft),
            ),
          const SizedBox(height: 16),
          TextField(controller: _title, decoration: InputDecoration(hintText: l10n.bookTitleField)),
          const SizedBox(height: 8),
          TextField(controller: _author, decoration: InputDecoration(hintText: l10n.bookAuthorField)),
          const SizedBox(height: 8),
          TextField(
            controller: _pages,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l10n.bookPagesField),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _title.text.trim().isEmpty
                ? null
                : () => _save(
                    BookDraft(
                      title: _title.text.trim(),
                      author: _author.text.trim().isEmpty ? null : _author.text.trim(),
                      totalPages: int.tryParse(_pages.text),
                    ),
                  ),
            child: Text(l10n.saveBook, style: TextStyle(color: colors.onInk)),
          ),
        ],
      ),
    );
  }

  Future<void> _search() async {
    setState(() => _searching = true);
    final results = await ref.read(bookMetadataProvider).search(_query.text);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  Future<void> _save(BookDraft draft) async {
    final now = DateTime.now().toUtc();
    await ref.read(bookRepositoryProvider).add(
      ShelfBook(
        id: createCaptureId(),
        title: draft.title,
        author: draft.author,
        coverUrl: draft.coverUrl,
        totalPages: draft.totalPages,
        isbn: draft.isbn,
        createdAt: now,
        updatedAt: now,
      ),
    );
    if (mounted) context.pop();
  }
}
