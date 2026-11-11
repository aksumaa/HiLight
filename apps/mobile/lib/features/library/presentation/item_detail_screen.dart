import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../../data/models/library_item.dart';
import '../../study/application/study_providers.dart';
import '../../study/presentation/word_sheet.dart';
import 'share_quote_card.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(libraryItemsProvider);
    return items.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.homeLoadError)),
      ),
      data: (list) {
        for (final item in list) {
          if (item.id == id) return _ItemBody(item: item);
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n.itemDetailTitle)),
          body: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.itemMissing)),
        );
      },
    );
  }
}

class _ItemBody extends ConsumerStatefulWidget {
  const _ItemBody({required this.item});

  final LibraryItem item;

  @override
  ConsumerState<_ItemBody> createState() => _ItemBodyState();
}

class _ItemBodyState extends ConsumerState<_ItemBody> {
  var _editing = false;
  late final TextEditingController _text;
  late final TextEditingController _tag;
  late final TextEditingController _page;
  late final TextEditingController _note;
  late final TextEditingController _chapter;
  late HighlightColor _color;
  late bool _favorite;
  String? _bookId;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.item.text);
    _tag = TextEditingController(text: widget.item.tag ?? '');
    _page = TextEditingController(text: widget.item.page?.toString() ?? '');
    _note = TextEditingController(text: widget.item.note ?? '');
    _chapter = TextEditingController(text: widget.item.chapter ?? '');
    _color = widget.item.highlightColor;
    _favorite = widget.item.favorite;
    _bookId = widget.item.bookId;
  }

  @override
  void dispose() {
    _text.dispose();
    _tag.dispose();
    _page.dispose();
    _note.dispose();
    _chapter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final item = widget.item;
    final accent = switch (item.type) {
      ItemType.quote => colors.quote,
      ItemType.voice => colors.voice,
      ItemType.note => colors.note,
      ItemType.ai => colors.ai,
    };
    final source = switch (item.source) {
      ItemSource.scan => l10n.sourceScan,
      ItemSource.voice => l10n.sourceVoice,
      ItemSource.manual => l10n.sourceManual,
      ItemSource.device => l10n.sourceDevice,
    };
    final language = switch (item.languageCode) {
      'ru' => l10n.languageRussian,
      'uz' => l10n.languageUzbek,
      _ => l10n.languageEnglish,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.itemDetailTitle),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: colors.secondary),
            onSelected: (value) {
              switch (value) {
                case 'copy':
                  _copy();
                case 'share':
                  shareQuoteCard(context, _text.text);
                case 'edit':
                  setState(() => _editing = true);
                case 'delete':
                  _delete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'copy', child: Text(l10n.itemCopy)),
              PopupMenuItem(value: 'share', child: Text(l10n.shareQuote)),
              if (!_editing) PopupMenuItem(value: 'edit', child: Text(l10n.itemEdit)),
              PopupMenuItem(value: 'delete', child: Text(l10n.itemDelete)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Row(
            children: [
              Container(
                width: 2,
                height: 16,
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Text(source, style: TextStyle(color: colors.secondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 20),
          if (_editing)
            TextField(
              controller: _text,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(labelText: l10n.editTextHint),
            )
          else
            Text(
              item.text.isEmpty ? l10n.statusPending : item.text,
              style: item.type == ItemType.quote
                  ? HilightTheme.quoteStyle(colors)
                  : const TextStyle(fontFamily: HilightTheme.uiFont, fontSize: 18, height: 1.4),
            ),
          const SizedBox(height: 12),
          if (!_editing)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final word in item.text.split(RegExp(r'[^A-Za-z]+')).where((part) => part.length > 2))
                  Semantics(
                    button: true,
                    label: word,
                    child: ActionChip(
                      label: Text(word),
                      onPressed: () => showWordSheet(context, ref, word: word, sentence: item.text, itemId: item.id),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              for (final color in HighlightColor.values)
                ChoiceChip(
                  label: Text(color.name),
                  selected: _color == color,
                  onSelected: (_) => setState(() => _color = color),
                ),
              FilterChip(
                label: Text(l10n.highlightFavorite),
                selected: _favorite,
                onSelected: (value) => setState(() => _favorite = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_editing) ...[
            TextField(controller: _note, decoration: InputDecoration(labelText: l10n.highlightNote)),
            const SizedBox(height: 12),
            TextField(controller: _chapter, decoration: InputDecoration(labelText: l10n.highlightChapter)),
            const SizedBox(height: 12),
            _BookPicker(
              bookId: _bookId,
              onChanged: (id) => setState(() => _bookId = id),
            ),
            const SizedBox(height: 12),
          ] else if (item.note != null) ...[
            Text(item.note!, style: TextStyle(color: colors.secondary, height: 1.4)),
            const SizedBox(height: 12),
          ],
          if (_editing) ...[
            TextField(controller: _tag, decoration: InputDecoration(labelText: l10n.editTag)),
            const SizedBox(height: 12),
            TextField(
              controller: _page,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.editPage),
            ),
          ] else ...[
            if (item.tag != null)
              Text('${l10n.editTag}: ${item.tag}', style: TextStyle(color: colors.secondary, fontSize: 14)),
            if (item.page != null)
              Text('${l10n.editPage}: ${item.page}', style: TextStyle(color: colors.secondary, fontSize: 14)),
            Text('${l10n.editLanguage}: $language', style: TextStyle(color: colors.secondary, fontSize: 14)),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _editing ? _save : () => context.push('/ai', extra: item),
            child: Text(_editing ? l10n.itemSave : l10n.discussAi),
          ),
        ],
      ),
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _text.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).itemCopied)),
    );
  }

  Future<void> _save() async {
    final tag = _tag.text.trim();
    final pageText = _page.text.trim();
    final note = _note.text.trim();
    final chapter = _chapter.text.trim();
    final updated = widget.item.copyWith(
      text: _text.text.trim(),
      tag: tag,
      page: int.tryParse(pageText),
      note: note,
      chapter: chapter,
      favorite: _favorite,
      highlightColor: _color,
      bookId: _bookId,
      clearTag: tag.isEmpty,
      clearPage: pageText.isEmpty,
      clearNote: note.isEmpty,
      clearChapter: chapter.isEmpty,
      clearBook: _bookId == null,
    );
    await ref.read(itemRepositoryProvider).update(updated);
    await ref.read(studyRepositoryProvider).ensureHighlightCards(itemId: updated.id, text: updated.text);
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.itemDeleteTitle),
          content: Text(l10n.itemDeleteBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.itemDeleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await ref.read(itemRepositoryProvider).delete(widget.item.id);
    if (mounted) context.pop();
  }
}

class _BookPicker extends ConsumerWidget {
  const _BookPicker({required this.bookId, required this.onChanged});

  final String? bookId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final books = ref.watch(booksProvider).value ?? const [];
    return DropdownButton<String?>(
      isExpanded: true,
      value: books.any((book) => book.id == bookId) ? bookId : null,
      hint: Text(l10n.assignBook),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(l10n.noBook)),
        for (final book in books) DropdownMenuItem<String?>(value: book.id, child: Text(book.title)),
      ],
      onChanged: onChanged,
    );
  }
}
