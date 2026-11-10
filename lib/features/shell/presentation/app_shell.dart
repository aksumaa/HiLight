import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final index = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Row(
            children: [
              _Tab(
                label: l10n.navHome,
                icon: Icons.home_outlined,
                selected: index == 0,
                onTap: () => navigationShell.goBranch(0),
              ),
              _Tab(
                label: l10n.navLibrary,
                icon: Icons.menu_book_outlined,
                selected: index == 1,
                onTap: () => navigationShell.goBranch(1),
              ),
              _CaptureButton(label: l10n.navCapture),
              _Tab(
                label: l10n.navInsights,
                icon: Icons.insights_outlined,
                selected: index == 2,
                onTap: () => navigationShell.goBranch(2),
              ),
              _Tab(
                label: l10n.navProfile,
                icon: Icons.person_outline,
                selected: index == 3,
                onTap: () => navigationShell.goBranch(3),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: colors.background,
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    final color = selected ? colors.primary : colors.secondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 11, fontFamily: HilightTheme.uiFont),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: colors.primary,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: colors.shadow,
            child: InkWell(
              key: const Key('capture-button'),
              customBorder: const CircleBorder(),
              onTap: () => showCaptureSheet(context),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.add, color: colors.card, size: 28),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: colors.primary, fontSize: 11, fontFamily: HilightTheme.uiFont),
          ),
        ],
      ),
    );
  }
}

Future<void> showCaptureSheet(BuildContext context) {
  final colors = context.hilight;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(HilightColors.radius)),
    ),
    builder: (sheetContext) {
      return _CaptureSheet(
        onChoose: (path) {
          Navigator.of(sheetContext).pop();
          context.push(path);
        },
      );
    },
  );
}

class _CaptureSheet extends StatelessWidget {
  const _CaptureSheet({required this.onChoose});

  final ValueChanged<String> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.captureSheetTitle, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => onChoose('/scan'), child: Text(l10n.homeScan)),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () => onChoose('/record'), child: Text(l10n.homeRecord)),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () => onChoose('/write'), child: Text(l10n.captureWrite)),
          ],
        ),
      ),
    );
  }
}
