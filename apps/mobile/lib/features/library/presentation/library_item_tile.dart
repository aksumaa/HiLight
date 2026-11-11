import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../../data/models/library_item.dart';

enum LibraryTileKind { list, card, compact }

class LibraryItemTile extends StatelessWidget {
  const LibraryItemTile({
    required this.item,
    required this.onOpen,
    this.kind = LibraryTileKind.list,
    super.key,
  });

  final LibraryItem item;
  final ValueChanged<LibraryItem> onOpen;
  final LibraryTileKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
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
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(item.createdAt);
    final body = item.text.isEmpty ? l10n.statusPending : item.text;
    final quote = item.type == ItemType.quote;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HilightColors.radius),
      side: BorderSide(color: colors.hairline),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(HilightColors.radius),
          boxShadow: colors.cardShadow,
        ),
        child: Material(
          color: colors.card,
          elevation: 0,
          shape: shape,
          child: InkWell(
            onTap: () => onOpen(item),
            customBorder: shape,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kind == LibraryTileKind.compact ? 16 : 20,
                vertical: kind == LibraryTileKind.card ? 24 : 18,
              ),
              child: kind == LibraryTileKind.compact
                  ? _Compact(accent: accent, body: body, date: date, colors: colors)
                  : _Full(
                      accent: accent,
                      source: source,
                      date: date,
                      body: body,
                      quote: quote,
                      pending: item.recognitionStatus == RecognitionStatus.pending,
                      colors: colors,
                      l10n: l10n,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Compact extends StatelessWidget {
  const _Compact({
    required this.accent,
    required this.body,
    required this.date,
    required this.colors,
  });

  final Color accent;
  final String body;
  final String date;
  final HilightColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 2,
          height: 16,
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: HilightTheme.uiFont, color: colors.text),
          ),
        ),
        const SizedBox(width: 8),
        Text(date, style: TextStyle(color: colors.secondary, fontSize: 13)),
      ],
    );
  }
}

class _Full extends StatelessWidget {
  const _Full({
    required this.accent,
    required this.source,
    required this.date,
    required this.body,
    required this.quote,
    required this.pending,
    required this.colors,
    required this.l10n,
  });

  final Color accent;
  final String source;
  final String date;
  final String body;
  final bool quote;
  final bool pending;
  final HilightColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 2,
              height: 14,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Text(
              source,
              style: TextStyle(
                color: colors.secondary,
                fontFamily: HilightTheme.uiFont,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(date, style: TextStyle(color: colors.secondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          body,
          maxLines: quote ? 6 : 4,
          overflow: TextOverflow.ellipsis,
          style: quote
              ? HilightTheme.quoteStyle(colors).copyWith(fontSize: 20)
              : const TextStyle(fontFamily: HilightTheme.uiFont, fontSize: 16, height: 1.35),
        ),
        if (pending) ...[
          const SizedBox(height: 8),
          Text(l10n.statusPending, style: TextStyle(color: colors.quote, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}
