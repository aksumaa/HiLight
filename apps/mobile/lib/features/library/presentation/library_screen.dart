import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../profile/application/settings_controller.dart';
import '../../books/presentation/books_view.dart';
import '../domain/library_query.dart';
import 'library_layouts.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _search = TextEditingController();
  var _filter = LibraryFilter.all;
  var _books = false;
  var _meaning = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final items = ref.watch(libraryItemsProvider);
    final layout = ref.watch(settingsProvider.select((settings) => settings.layout));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              key: const Key('library-search'),
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.librarySearch,
                prefixIcon: Icon(Icons.search, color: colors.secondary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: l10n.feedTitle,
                  selected: !_books,
                  chipKey: const Key('library-feed'),
                  onSelected: () => setState(() => _books = false),
                ),
                _FilterChip(
                  label: l10n.booksTitle,
                  selected: _books,
                  chipKey: const Key('library-books'),
                  onSelected: () => setState(() => _books = true),
                ),
                _FilterChip(
                  label: _meaning ? l10n.searchMeaning : l10n.searchWords,
                  selected: _meaning,
                  chipKey: const Key('library-meaning'),
                  onSelected: () => setState(() => _meaning = !_meaning),
                ),
                _FilterChip(
                  label: l10n.importTitle,
                  selected: false,
                  chipKey: const Key('library-import'),
                  onSelected: () => context.push('/import'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final filter in LibraryFilter.values) ...[
                  _FilterChip(
                    label: _label(l10n, filter),
                    selected: _filter == filter,
                    chipKey: Key('filter-${filter.name}'),
                    onSelected: () => setState(() => _filter = filter),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.homeLoadError),
              ),
              data: (list) {
                if (_books) return BooksView(items: list);
                if (list.isEmpty) return _Empty(text: l10n.libraryEmpty);
                final visible = filterLibrary(list, filter: _filter, query: _search.text, meaning: _meaning);
                if (visible.isEmpty) return _Empty(text: l10n.libraryNoMatches);
                return layoutFor(layout).build(
                  context,
                  visible,
                  (item) => context.push('/item/${item.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n, LibraryFilter filter) {
    return switch (filter) {
      LibraryFilter.all => l10n.filterAll,
      LibraryFilter.quote => l10n.filterQuotes,
      LibraryFilter.voice => l10n.filterVoice,
      LibraryFilter.note => l10n.filterNotes,
      LibraryFilter.ai => l10n.filterAi,
    };
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.chipKey,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final Key chipKey;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return ChoiceChip(
      key: chipKey,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: colors.card,
      backgroundColor: colors.card,
      labelStyle: TextStyle(
        fontFamily: HilightTheme.uiFont,
        fontSize: 14,
        fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
        color: selected ? colors.primary : colors.text,
      ),
      side: BorderSide(color: selected ? colors.primary.withValues(alpha: 0.45) : colors.hairline),
      shape: const StadiumBorder(),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        key: const Key('library-empty'),
        style: TextStyle(color: context.hilight.secondary, height: 1.4),
      ),
    );
  }
}
