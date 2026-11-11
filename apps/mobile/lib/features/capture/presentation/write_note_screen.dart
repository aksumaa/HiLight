import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../capture/domain/capture_event.dart';

class WriteNoteScreen extends ConsumerStatefulWidget {
  const WriteNoteScreen({super.key});

  @override
  ConsumerState<WriteNoteScreen> createState() => _WriteNoteScreenState();
}

class _WriteNoteScreenState extends ConsumerState<WriteNoteScreen> {
  final _text = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.writeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _text,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(hintText: l10n.writeHint),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.editHelper,
            style: TextStyle(color: context.hilight.secondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _continue,
            child: Text(l10n.writeContinue),
          ),
        ],
      ),
    );
  }

  Future<void> _continue() async {
    final text = _text.text.trim();
    final l10n = AppLocalizations.of(context);
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.writeEmpty)));
      return;
    }
    setState(() => _busy = true);
    try {
      final language = ref.read(captureLanguageProvider);
      final event = await ref.read(manualInputSourceProvider).capture(
        CaptureInput(languageCode: language, text: text),
      );
      final processed = await ref.read(capturePipelineProvider).process(event);
      if (!mounted) return;
      await context.push('/capture/edit', extra: processed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
