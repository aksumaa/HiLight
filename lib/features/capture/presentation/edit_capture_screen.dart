import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../../data/models/library_item.dart';
import '../domain/capture_event.dart';
import '../domain/capture_pipeline.dart';
import 'language_chips.dart';
import 'local_audio_player.dart';

class EditCaptureScreen extends ConsumerStatefulWidget {
  const EditCaptureScreen({required this.processed, super.key});

  final ProcessedCapture processed;

  @override
  ConsumerState<EditCaptureScreen> createState() => _EditCaptureScreenState();
}

class _EditCaptureScreenState extends ConsumerState<EditCaptureScreen> {
  late ProcessedCapture _processed;
  late final TextEditingController _text;
  late final TextEditingController _tag;
  late final TextEditingController _page;
  late String _language;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _processed = widget.processed;
    _text = TextEditingController(text: _processed.text);
    _tag = TextEditingController();
    _page = TextEditingController();
    _language = _processed.event.languageCode;
  }

  @override
  void dispose() {
    _text.dispose();
    _tag.dispose();
    _page.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    await ref.read(capturePipelineProvider).save(
      _processed,
      text: _text.text,
      tag: _tag.text,
      page: int.tryParse(_page.text.trim()),
      languageCode: _language,
    );
    if (mounted) context.go('/');
  }

  Future<void> _discard() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardTitle),
        content: Text(l10n.discardBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discardAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(capturePipelineProvider).discard(_processed);
    if (mounted) context.go('/');
  }

  Future<void> _again() async {
    setState(() => _busy = true);
    final again = await ref.read(capturePipelineProvider).process(
      _processed.event.copyWith(languageCode: _language),
      storePending: false,
    );
    if (!mounted) return;
    setState(() {
      _processed = ProcessedCapture(
        event: again.event,
        outcome: again.outcome,
        text: again.text,
        usedStub: again.usedStub,
        saved: _processed.saved,
      );
      _text.text = again.text;
      _busy = false;
    });
  }

  Future<void> _leave() async {
    if (_processed.saved != null) {
      context.pop();
      return;
    }
    await _discard();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final quote = _processed.event.type == ItemType.quote;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.editTitle)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            if (_processed.event.imagePath != null) _thumbnail(colors),
            if (_processed.event.audioPath != null)
              LocalAudioPlayer(path: _processed.event.audioPath!),
            const SizedBox(height: 16),
            _banner(l10n, colors),
            TextField(
              controller: _text,
              minLines: 6,
              maxLines: 12,
              style: quote
                  ? HilightTheme.quoteStyle(colors)
                  : TextStyle(fontFamily: HilightTheme.uiFont, fontSize: 16, color: colors.text),
              decoration: InputDecoration(hintText: l10n.editTextHint),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.editHelper,
              style: TextStyle(color: colors.secondary, fontFamily: HilightTheme.uiFont),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tag,
              decoration: InputDecoration(labelText: l10n.editTag),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _page,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.editPage),
            ),
            const SizedBox(height: 16),
            Text(l10n.editLanguage, style: TextStyle(color: colors.secondary)),
            const SizedBox(height: 8),
            LanguageChips(
              value: _language,
              onChanged: (code) => setState(() => _language = code),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _busy ? null : _again,
              child: Text(l10n.editRecognizeAgain),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(l10n.editSave),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _busy ? null : _discard, child: Text(l10n.editDiscard)),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(HilightColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HilightColors.radius),
        child: Image.file(
          File(_processed.event.imagePath!),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => SizedBox(
            height: 180,
            child: ColoredBox(color: colors.card),
          ),
        ),
      ),
    );
  }

  Widget _banner(AppLocalizations l10n, HilightColors colors) {
    final message = switch (_processed.outcome) {
      CaptureOutcome.pendingOffline => l10n.editPending,
      CaptureOutcome.empty => l10n.editEmpty,
      CaptureOutcome.failed => l10n.editFailed,
      CaptureOutcome.tooLong => l10n.editTooLong(kMaxRecording.inMinutes),
      CaptureOutcome.recognized when _processed.usedStub => l10n.editStub,
      CaptureOutcome.recognized => null,
    };
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(HilightColors.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(message, style: TextStyle(color: colors.secondary)),
        ),
      ),
    );
  }
}
