import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../../data/models/library_item.dart';

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

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.item.text);
    _tag = TextEditingController(text: widget.item.tag ?? '');
    _page = TextEditingController(text: widget.item.page?.toString() ?? '');
  }

  @override
  void dispose() {
    _text.dispose();
    _tag.dispose();
    _page.dispose();
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
      appBar: AppBar(title: Text(l10n.itemDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(source, style: TextStyle(color: colors.secondary)),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          if (_editing) ...[
            TextField(controller: _tag, decoration: InputDecoration(labelText: l10n.editTag)),
            const SizedBox(height: 12),
            TextField(
              controller: _page,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.editPage),
            ),
          ] else ...[
            if (item.tag != null) Text('${l10n.editTag}: ${item.tag}'),
            if (item.page != null) Text('${l10n.editPage}: ${item.page}'),
            Text('${l10n.editLanguage}: $language'),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(onPressed: _copy, child: Text(l10n.itemCopy)),
              OutlinedButton(
                onPressed: _editing ? _save : () => setState(() => _editing = true),
                child: Text(_editing ? l10n.itemSave : l10n.itemEdit),
              ),
              OutlinedButton(onPressed: _delete, child: Text(l10n.itemDelete)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('/ai', extra: item),
            child: Text(l10n.discussAi),
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
    final updated = widget.item.copyWith(
      text: _text.text.trim(),
      tag: tag,
      page: int.tryParse(pageText),
      clearTag: tag.isEmpty,
      clearPage: pageText.isEmpty,
    );
    await ref.read(itemRepositoryProvider).update(updated);
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
