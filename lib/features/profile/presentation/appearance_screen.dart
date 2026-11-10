import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../capture/presentation/language_chips.dart';
import '../../library/presentation/library_widgets.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SectionLabel(l10n.appearanceLanguage),
          const SizedBox(height: 8),
          LanguageChips(
            value: settings.localeCode,
            onChanged: notifier.setLocale,
          ),
          const SizedBox(height: 24),
          SectionLabel(l10n.appearanceTheme),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _Choice(
                label: l10n.themeSystem,
                selected: settings.theme == AppThemeChoice.system,
                chipKey: const Key('theme-system'),
                onTap: () => notifier.setTheme(AppThemeChoice.system),
              ),
              _Choice(
                label: l10n.themeLight,
                selected: settings.theme == AppThemeChoice.light,
                chipKey: const Key('theme-light'),
                onTap: () => notifier.setTheme(AppThemeChoice.light),
              ),
              _Choice(
                label: l10n.themeDark,
                selected: settings.theme == AppThemeChoice.dark,
                chipKey: const Key('theme-dark'),
                onTap: () => notifier.setTheme(AppThemeChoice.dark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionLabel(l10n.appearanceLayout),
          const SizedBox(height: 8),
          Row(
            children: [
              _LayoutPreview(
                label: l10n.layoutList,
                kind: LibraryLayoutKind.list,
                selected: settings.layout == LibraryLayoutKind.list,
                previewKey: const Key('layout-list'),
                onTap: () => notifier.setLayout(LibraryLayoutKind.list),
              ),
              const SizedBox(width: 8),
              _LayoutPreview(
                label: l10n.layoutCards,
                kind: LibraryLayoutKind.cards,
                selected: settings.layout == LibraryLayoutKind.cards,
                previewKey: const Key('layout-cards'),
                onTap: () => notifier.setLayout(LibraryLayoutKind.cards),
              ),
              const SizedBox(width: 8),
              _LayoutPreview(
                label: l10n.layoutCompact,
                kind: LibraryLayoutKind.compact,
                selected: settings.layout == LibraryLayoutKind.compact,
                previewKey: const Key('layout-compact'),
                onTap: () => notifier.setLayout(LibraryLayoutKind.compact),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionLabel(l10n.appearanceAccent),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final choice in AccentChoice.values) ...[
                _AccentDot(
                  color: accentColor(choice),
                  selected: settings.accent == choice,
                  dotKey: Key('accent-${choice.name}'),
                  onTap: () => notifier.setAccent(choice),
                ),
                const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 24),
          SectionLabel(l10n.appearanceFont),
          Slider(
            value: settings.fontScale,
            min: 0.85,
            max: 1.35,
            divisions: 4,
            label: settings.fontScale.toStringAsFixed(2),
            onChanged: notifier.setFontScale,
          ),
          const SizedBox(height: 8),
          SectionLabel(l10n.appearancePreview),
          const SizedBox(height: 8),
          _LivePreview(settings: settings),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.chipKey,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Key chipKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return ChoiceChip(
      key: chipKey,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: colors.primary,
      backgroundColor: colors.card,
      labelStyle: TextStyle(
        fontFamily: HilightTheme.uiFont,
        color: selected ? colors.card : colors.text,
      ),
    );
  }
}

class _LayoutPreview extends StatelessWidget {
  const _LayoutPreview({
    required this.label,
    required this.kind,
    required this.selected,
    required this.previewKey,
    required this.onTap,
  });

  final String label;
  final LibraryLayoutKind kind;
  final bool selected;
  final Key previewKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return Expanded(
      child: InkWell(
        key: previewKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : colors.secondary.withValues(alpha: 0.35),
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _Mini(kind: kind),
                const SizedBox(height: 8),
                Text(label, style: TextStyle(fontSize: 12, color: colors.text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.kind});

  final LibraryLayoutKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    final bar = colors.secondary.withValues(alpha: 0.35);
    if (kind == LibraryLayoutKind.compact) {
      return Column(
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              height: 6,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(color: bar, borderRadius: BorderRadius.circular(4)),
            ),
        ],
      );
    }
    if (kind == LibraryLayoutKind.cards) {
      return Container(
        height: 36,
        decoration: BoxDecoration(color: bar, borderRadius: BorderRadius.circular(8)),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < 2; i++)
          Container(
            height: 14,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(color: bar, borderRadius: BorderRadius.circular(6)),
          ),
      ],
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.color,
    required this.selected,
    required this.dotKey,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final Key dotKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: dotKey,
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? context.hilight.text : context.hilight.card,
            width: 3,
          ),
        ),
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final accent = accentColor(settings.accent);
    final compact = settings.layout == LibraryLayoutKind.compact;
    return DecoratedBox(
      key: const Key('appearance-preview'),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(HilightColors.radius),
        boxShadow: colors.cardShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 18),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.previewSample,
                maxLines: compact ? 1 : 3,
                overflow: TextOverflow.ellipsis,
                style: settings.layout == LibraryLayoutKind.cards
                    ? HilightTheme.quoteStyle(colors).copyWith(fontSize: 18)
                    : const TextStyle(fontFamily: HilightTheme.uiFont, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
