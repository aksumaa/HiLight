import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../domain/library_query.dart';
import 'library_item_tile.dart';
import 'library_widgets.dart';

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
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.homeEmpty,
                style: TextStyle(color: colors.secondary, height: 1.4),
              ),
            );
          }
          final feed = HomeFeed.from(list);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              SectionLabel(l10n.todayReview),
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

