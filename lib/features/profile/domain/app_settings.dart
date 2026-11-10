import 'package:flutter/material.dart';

import '../../../core/theme/hilight_colors.dart';

enum AppThemeChoice { system, light, dark }

enum LibraryLayoutKind { list, cards, compact }

enum AccentChoice { quote, voice, note, ai }

class AppSettings {
  const AppSettings({
    required this.theme,
    required this.localeCode,
    required this.layout,
    required this.accent,
    required this.fontScale,
    required this.onboardingComplete,
    required this.gatePassed,
  });

  final AppThemeChoice theme;
  final String localeCode;
  final LibraryLayoutKind layout;
  final AccentChoice accent;
  final double fontScale;
  final bool onboardingComplete;
  final bool gatePassed;

  ThemeMode get themeMode => switch (theme) {
    AppThemeChoice.system => ThemeMode.system,
    AppThemeChoice.light => ThemeMode.light,
    AppThemeChoice.dark => ThemeMode.dark,
  };

  AppSettings copyWith({
    AppThemeChoice? theme,
    String? localeCode,
    LibraryLayoutKind? layout,
    AccentChoice? accent,
    double? fontScale,
    bool? onboardingComplete,
    bool? gatePassed,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      localeCode: localeCode ?? this.localeCode,
      layout: layout ?? this.layout,
      accent: accent ?? this.accent,
      fontScale: fontScale ?? this.fontScale,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      gatePassed: gatePassed ?? this.gatePassed,
    );
  }
}

Color accentColor(AccentChoice choice) {
  return switch (choice) {
    AccentChoice.quote => HilightColors.light.quote,
    AccentChoice.voice => HilightColors.light.voice,
    AccentChoice.note => HilightColors.light.note,
    AccentChoice.ai => HilightColors.light.ai,
  };
}

Color accentTint(AccentChoice choice) {
  return switch (choice) {
    AccentChoice.quote => HilightColors.light.quoteTint,
    AccentChoice.voice => HilightColors.light.voiceTint,
    AccentChoice.note => HilightColors.light.noteTint,
    AccentChoice.ai => HilightColors.light.aiTint,
  };
}
