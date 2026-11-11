import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../data/models/library_item.dart';
import '../../capture/domain/capture_event.dart';
import '../../capture/domain/capture_file_store.dart';
import '../../profile/application/settings_controller.dart';
import '../domain/pronunciation.dart';

class PronounceScreen extends ConsumerStatefulWidget {
  const PronounceScreen({required this.word, super.key});

  final String word;

  @override
  ConsumerState<PronounceScreen> createState() => _PronounceScreenState();
}

class _PronounceScreenState extends ConsumerState<PronounceScreen> {
  final _recorder = AudioRecorder();
  var _recording = false;
  var _busy = false;
  String? _heard;
  int? _score;
  var _unavailable = false;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    return Scaffold(
      appBar: AppBar(title: Text(widget.word)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(l10n.pronounceRough, style: TextStyle(color: colors.secondary, height: 1.4)),
          const SizedBox(height: 16),
          Text(widget.word, style: TextStyle(fontSize: 28, color: colors.text, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : (_recording ? _stop : _start),
            child: Text(_recording ? l10n.pronounceStop : l10n.pronounceRecord),
          ),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator(minHeight: 2)),
          if (_unavailable)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(l10n.pronounceMissed, style: TextStyle(color: colors.secondary, height: 1.4)),
            ),
          if (_score != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                '$_score · ${_heard ?? ''}',
                style: TextStyle(color: colors.text, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _start() async {
    final allowed = await _recorder.hasPermission();
    if (!mounted) return;
    if (!allowed) {
      setState(() => _unavailable = true);
      return;
    }
    final path = await ref.read(captureFileStoreProvider).allocateFile(folder: 'audio', extension: 'm4a');
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    if (mounted) setState(() => _recording = true);
  }

  Future<void> _stop() async {
    setState(() {
      _recording = false;
      _busy = true;
      _unavailable = false;
    });
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    final event = CaptureEvent(
      id: createCaptureId(),
      type: ItemType.voice,
      source: ItemSource.voice,
      audioPath: path,
      languageCode: ref.read(settingsProvider).localeCode,
      createdAt: DateTime.now().toUtc(),
    );
    final processed = await ref.read(capturePipelineProvider).process(event, storePending: false);
    if (!mounted) return;
    final heard = processed.text.trim();
    if (heard.isEmpty) {
      setState(() {
        _busy = false;
        _unavailable = true;
        _score = null;
      });
      return;
    }
    setState(() {
      _busy = false;
      _heard = heard;
      _score = pronunciationScore(widget.word, heard);
    });
  }
}
