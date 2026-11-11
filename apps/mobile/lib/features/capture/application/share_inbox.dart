import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../profile/application/settings_controller.dart';
import '../../widget/application/widget_bridge.dart';
import '../domain/shared_inbox.dart';

class ShareInboxHost extends ConsumerStatefulWidget {
  const ShareInboxHost({super.key});

  @override
  ConsumerState<ShareInboxHost> createState() => _ShareInboxHostState();
}

class _ShareInboxHostState extends ConsumerState<ShareInboxHost> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _drain());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _drain();
  }

  Future<void> _drain() async {
    List<Object?> rows;
    try {
      rows = await sharedContainerChannel.invokeMethod<List<Object?>>('readInbox') ?? const [];
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
    final pipeline = ref.read(capturePipelineProvider);
    final language = ref.read(settingsProvider).localeCode;
    var saved = 0;
    for (final row in rows) {
      if (row is! Map) continue;
      final share = SharedCapture.fromMap(row);
      final event = eventForShare(share, languageCode: language);
      if (event == null) {
        await _consume(share.id);
        continue;
      }
      final processed = await pipeline.process(event);
      await pipeline.save(processed, text: processed.text);
      await _consume(share.id);
      saved += 1;
    }
    if (saved == 0 || !mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).shareSaved)));
  }

  Future<void> _consume(String id) async {
    try {
      await sharedContainerChannel.invokeMethod<void>('consumeInbox', {'id': id});
    } on PlatformException {
      return;
    }
  }
}
