import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../capture/domain/capture_event.dart';

class DeviceScreen extends ConsumerStatefulWidget {
  const DeviceScreen({super.key});

  @override
  ConsumerState<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends ConsumerState<DeviceScreen> {
  String? _lastText;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.deviceTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            l10n.deviceBody,
            style: TextStyle(color: colors.secondary, height: 1.45, fontFamily: HilightTheme.uiFont),
          ),
          const SizedBox(height: 20),
          if (_lastText != null)
            DecoratedBox(
              decoration: colors.surface(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(_lastText!, style: HilightTheme.quoteStyle(colors).copyWith(fontSize: 20)),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _send,
            child: Text(l10n.deviceSend),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final event = await ref.read(mockDeviceSourceProvider).capture(
        CaptureInput(
          languageCode: ref.read(captureLanguageProvider),
          text: l10n.deviceSample,
        ),
      );
      final processed = await ref.read(capturePipelineProvider).process(event);
      await ref.read(capturePipelineProvider).save(
        processed,
        text: processed.text,
        languageCode: event.languageCode,
      );
      if (!mounted) return;
      setState(() => _lastText = event.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deviceSaved)));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deviceFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
