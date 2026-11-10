import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/hilight_theme.dart';
import '../features/profile/application/settings_controller.dart';
import '../features/profile/domain/app_settings.dart';
import 'app_router.dart';

class HiLightApp extends ConsumerWidget {
  const HiLightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    final accent = accentColor(settings.accent);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: router,
      theme: HilightTheme.light(accent: accent),
      darkTheme: HilightTheme.dark(accent: accent),
      themeMode: settings.themeMode,
      locale: Locale(settings.localeCode),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
