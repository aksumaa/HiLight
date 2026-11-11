import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';

Future<void> shareQuoteCard(BuildContext context, String text) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => _ShareSheet(text: text),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.text});

  final String text;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _key = GlobalKey();
  var _template = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: _key,
            child: _Card(text: widget.text, template: _template),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${i + 1}'),
                    selected: _template == i,
                    onSelected: (_) => setState(() => _template = i),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final boundary = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 3);
              final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
              if (bytes == null) return;
              final file = File('${(await getTemporaryDirectory()).path}/hilight-quote.png');
              await file.writeAsBytes(bytes.buffer.asUint8List());
              await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: widget.text));
            },
            child: Text(l10n.shareQuote, style: TextStyle(color: colors.onInk)),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.text, required this.template});

  final String text;
  final int template;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    final accent = switch (template) {
      1 => colors.voice,
      2 => colors.ai,
      _ => colors.quote,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: template == 2 ? colors.ink : colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 28, height: 2, color: accent),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontFamily: template == 0 ? HilightTheme.quoteFont : HilightTheme.uiFont,
              fontSize: 18,
              height: 1.4,
              color: template == 2 ? colors.onInk : colors.text,
            ),
          ),
        ],
      ),
    );
  }
}
