import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../domain/capture_event.dart';
import '../domain/capture_source.dart';
import 'language_chips.dart';
import 'permission_denied_view.dart';
import 'waveform_bars.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  final _recorder = AudioRecorder();
  final _levels = List<double>.filled(28, 0.05);
  Timer? _ticker;
  StreamSubscription<Amplitude>? _amplitudes;
  Stopwatch _elapsed = Stopwatch();
  String? _path;
  var _denied = false;
  var _recording = false;
  var _paused = false;
  var _working = false;
  var _hitLimit = false;

  @override
  void dispose() {
    _ticker?.cancel();
    _amplitudes?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final allowed = await _recorder.hasPermission();
    if (!mounted) return;
    if (!allowed) {
      setState(() => _denied = true);
      return;
    }
    final path = await ref
        .read(captureFileStoreProvider)
        .allocateFile(folder: 'audio', extension: 'm4a');
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
    _amplitudes = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen((amplitude) {
          if (!mounted) return;
          setState(() {
            _levels.removeAt(0);
            _levels.add(waveformLevel(amplitude.current));
          });
        });
    _elapsed = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || !_elapsed.isRunning) return;
      if (_elapsed.elapsed >= kMaxRecording) {
        _stop(hitLimit: true);
        return;
      }
      setState(() {});
    });
    setState(() {
      _path = path;
      _recording = true;
      _paused = false;
      _hitLimit = false;
    });
  }

  Future<void> _pause() async {
    if (_paused) {
      await _recorder.resume();
      _elapsed.start();
    } else {
      await _recorder.pause();
      _elapsed.stop();
    }
    if (mounted) setState(() => _paused = !_paused);
  }

  Future<void> _stop({bool hitLimit = false}) async {
    if (_working) return;
    setState(() => _working = true);
    _ticker?.cancel();
    _elapsed.stop();
    await _amplitudes?.cancel();
    final path = await _recorder.stop();
    final stored = path ?? _path;
    if (!mounted || stored == null) return;
    final language = ref.read(captureLanguageProvider);
    final event = await ref.read(phoneMicSourceProvider).capture(
      CaptureInput(
        filePath: stored,
        languageCode: language,
        duration: _elapsed.elapsed,
      ),
    );
    final processed = await ref.read(capturePipelineProvider).process(event);
    if (!mounted) return;
    setState(() {
      _recording = false;
      _working = false;
      _hitLimit = hitLimit;
    });
    await context.push('/capture/edit', extra: processed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_denied) {
      return PermissionDeniedView(
        title: l10n.recordPermissionTitle,
        body: l10n.recordPermissionBody,
      );
    }
    final colors = context.hilight;
    final elapsed = _format(_elapsed.elapsed);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordTitle)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LanguageChips(),
            const Spacer(),
            Text(
              elapsed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            WaveformBars(levels: _levels),
            if (_hitLimit) ...[
              const SizedBox(height: 12),
              Text(
                l10n.recordTooLong(kMaxRecording.inMinutes),
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.secondary, fontFamily: HilightTheme.uiFont),
              ),
            ],
            if (_working) ...[
              const SizedBox(height: 16),
              Text(l10n.recordProcessing, textAlign: TextAlign.center),
            ],
            const Spacer(),
            if (!_recording)
              FilledButton(onPressed: _working ? null : _start, child: Text(l10n.recordTitle))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _working ? null : _pause,
                      child: Text(_paused ? l10n.recordResume : l10n.recordPause),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _working ? null : () => _stop(),
                      child: Text(l10n.recordStop),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
