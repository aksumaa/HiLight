import 'package:flutter/material.dart';

import '../../../core/theme/hilight_colors.dart';

enum AppThemeChoice { system, light, dark }

enum LibraryLayoutKind { list, cards, compact }

enum AccentChoice { quote, voice, note, ai }

enum LearningGoal { reader, learner, both }

class AppSettings {
  const AppSettings({
    required this.theme,
    required this.localeCode,
    required this.layout,
    required this.accent,
    required this.fontScale,
    required this.onboardingComplete,
    required this.gatePassed,
    this.goal = LearningGoal.both,
    this.reviewHour = 20,
    this.reviewMinute = 0,
    this.dailyNewLimit = 10,
    this.dailyReviewLimit = 20,
    this.dailyReadingMinutes = 15,
  });

  final AppThemeChoice theme;
  final String localeCode;
  final LibraryLayoutKind layout;
  final AccentChoice accent;
  final double fontScale;
  final bool onboardingComplete;
  final bool gatePassed;
  final LearningGoal goal;
  final int reviewHour;
  final int reviewMinute;
  final int dailyNewLimit;
  final int dailyReviewLimit;
  final int dailyReadingMinutes;

  bool get showsReaderHome => goal == LearningGoal.reader || goal == LearningGoal.both;

  bool get showsLearnerHome => goal == LearningGoal.learner || goal == LearningGoal.both;

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
    LearningGoal? goal,
    int? reviewHour,
    int? reviewMinute,
    int? dailyNewLimit,
    int? dailyReviewLimit,
    int? dailyReadingMinutes,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      localeCode: localeCode ?? this.localeCode,
      layout: layout ?? this.layout,
      accent: accent ?? this.accent,
      fontScale: fontScale ?? this.fontScale,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      gatePassed: gatePassed ?? this.gatePassed,
      goal: goal ?? this.goal,
      reviewHour: reviewHour ?? this.reviewHour,
      reviewMinute: reviewMinute ?? this.reviewMinute,
      dailyNewLimit: dailyNewLimit ?? this.dailyNewLimit,
      dailyReviewLimit: dailyReviewLimit ?? this.dailyReviewLimit,
      dailyReadingMinutes: dailyReadingMinutes ?? this.dailyReadingMinutes,
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
