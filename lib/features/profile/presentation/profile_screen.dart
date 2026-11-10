import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../library/presentation/library_widgets.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final language = switch (settings.localeCode) {
      'ru' => l10n.languageRussian,
      'uz' => l10n.languageUzbek,
      _ => l10n.languageEnglish,
    };
    final theme = switch (settings.theme) {
      AppThemeChoice.system => l10n.themeSystem,
      AppThemeChoice.light => l10n.themeLight,
      AppThemeChoice.dark => l10n.themeDark,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: const [SyncIconButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          ListTile(
            title: Text(l10n.appearanceTitle),
            subtitle: Text('$language · $theme'),
            trailing: Icon(Icons.chevron_right, color: context.hilight.secondary),
            onTap: () => context.push('/appearance'),
          ),
          ListTile(
            title: Text(l10n.accountTitle),
            trailing: Icon(Icons.chevron_right, color: context.hilight.secondary),
            onTap: () => context.push('/account'),
          ),
          ListTile(
            title: Text(l10n.deviceTitle),
            trailing: Icon(Icons.chevron_right, color: context.hilight.secondary),
            onTap: () => context.push('/device'),
          ),
          ListTile(
            title: Text(l10n.syncNow),
            onTap: () => syncLibrary(context, ref),
          ),
        ],
      ),
    );
  }
}
