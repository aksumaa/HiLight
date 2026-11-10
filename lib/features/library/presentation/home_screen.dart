import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_providers.dart';
import '../../../data/sync/sync_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../../data/models/library_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final items = ref.watch(libraryItemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            tooltip: l10n.syncNow,
            onPressed: () => _sync(context, ref),
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: l10n.accountTitle,
            onPressed: () => context.push('/account'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.homeLoadError),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.homeEmpty,
                      style: TextStyle(
                        color: colors.secondary,
                        fontFamily: HilightTheme.uiFont,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  children: [
                    Text(
                      l10n.homeRecent,
                      style: TextStyle(color: colors.secondary, fontFamily: HilightTheme.uiFont),
                    ),
                    const SizedBox(height: 12),
                    for (final item in list) ...[
                      _ItemCard(item: item),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push('/scan'),
                    child: Text(l10n.homeScan),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/record'),
                    child: Text(l10n.homeRecord),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _sync(BuildContext context, WidgetRef ref) async {
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

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final LibraryItem item;

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
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(item.createdAt);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(HilightColors.radius),
        boxShadow: colors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(source, style: TextStyle(color: colors.secondary, fontFamily: HilightTheme.uiFont)),
                const Spacer(),
                Text(date, style: TextStyle(color: colors.secondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.text.isEmpty ? l10n.statusPending : item.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: item.type == ItemType.quote
                  ? HilightTheme.quoteStyle(colors).copyWith(fontSize: 18)
                  : const TextStyle(fontFamily: HilightTheme.uiFont, fontSize: 16, height: 1.35),
            ),
            if (item.recognitionStatus == RecognitionStatus.pending) ...[
              const SizedBox(height: 8),
              Text(l10n.statusPending, style: TextStyle(color: colors.quote, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
