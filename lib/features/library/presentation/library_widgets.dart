import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../../data/sync/sync_service.dart';

class SyncIconButton extends ConsumerWidget {
  const SyncIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context).syncNow,
      onPressed: () => syncLibrary(context, ref),
      icon: const Icon(Icons.sync),
    );
  }
}

Future<void> syncLibrary(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final outcome = await ref.read(syncServiceProvider).run();
  if (!context.mounted) return;
  final message = switch (outcome) {
    SyncOutcome.done => l10n.syncDone,
    SyncOutcome.needsAccount => l10n.syncNeedsAccount,
    SyncOutcome.failed => l10n.syncFailed,
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String greetingFor(AppLocalizations l10n, DateTime now) {
  if (now.hour < 12) return l10n.greetingMorning;
  if (now.hour < 18) return l10n.greetingAfternoon;
  return l10n.greetingEvening;
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.hilight.secondary,
        fontFamily: HilightTheme.uiFont,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
