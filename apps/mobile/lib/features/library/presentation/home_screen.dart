import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../profile/application/settings_controller.dart';
import '../../study/application/study_providers.dart';
import '../domain/library_query.dart';
import 'library_item_tile.dart';
import 'library_widgets.dart';

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.title, required this.subtitle, this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return Semantics(
      button: onTap != null,
      label: '$subtitle, $title',
      child: DecoratedBox(
        decoration: colors.surface(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(HilightColors.radius),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: HilightTheme.uiFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: colors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final items = ref.watch(libraryItemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(greetingFor(l10n, DateTime.now())),
        actions: const [SyncIconButton()],
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.homeLoadError),
        ),
        data: (list) {
          final settings = ref.watch(settingsProvider);
          final feed = HomeFeed.from(list);
          final due = ref.watch(reviewDueCountProvider);
          final word = ref.watch(wordOfDayProvider);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              if (settings.showsLearnerHome) ...[
                SectionLabel(l10n.homeReviewDue),
                const SizedBox(height: 12),
                _HomeCard(
                  title: '$due',
                  subtitle: l10n.homeReviewDue,
                  onTap: () => context.push('/review'),
                ),
                const SizedBox(height: 16),
                SectionLabel(l10n.homeWordOfDay),
                const SizedBox(height: 12),
                _HomeCard(
                  title: word ?? l10n.homeWordOfDayEmpty,
                  subtitle: l10n.homeWordOfDay,
                  onTap: word == null ? null : () => context.push('/vocab'),
                ),
                const SizedBox(height: 16),
              ],
              if (settings.showsReaderHome) ...[
              SectionLabel(l10n.homeHighlights),
              const SizedBox(height: 12),
              if (feed.review.isEmpty)
                Text(l10n.todayReviewEmpty, style: TextStyle(color: colors.secondary))
              else
                for (final item in feed.review)
                  LibraryItemTile(
                    item: item,
                    onOpen: (item) => context.push('/item/${item.id}'),
                  ),
              const SizedBox(height: 16),
              ],
              if (list.isEmpty)
                Text(l10n.homeEmpty, style: TextStyle(color: colors.secondary, height: 1.4)),
              SectionLabel(l10n.homeRecent),
              const SizedBox(height: 12),
              if (feed.recent.isEmpty)
                Text(l10n.todayReviewEmpty, style: TextStyle(color: colors.secondary))
              else
                for (final item in feed.recent)
                  LibraryItemTile(
                    item: item,
                    onOpen: (item) => context.push('/item/${item.id}'),
                  ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: colors.surface(),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/ai'),
                    borderRadius: BorderRadius.circular(HilightColors.radius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 2,
                            height: 18,
                            decoration: BoxDecoration(
                              color: colors.ai,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.askAi,
                              style: TextStyle(
                                fontFamily: HilightTheme.uiFont,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: colors.text,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: colors.secondary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

