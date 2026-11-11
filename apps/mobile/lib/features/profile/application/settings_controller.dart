import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_providers.dart';
import '../domain/app_settings.dart';

class SettingsController extends Notifier<AppSettings> {
  static const themeKey = 'theme_mode';
  static const localeKey = 'app_locale';
  static const layoutKey = 'library_layout';
  static const accentKey = 'accent_choice';
  static const fontKey = 'font_scale';
  static const onboardingKey = 'onboarding_complete';
  static const gateKey = 'gate_passed';
  static const goalKey = 'learning_goal';
  static const reviewHourKey = 'review_hour';
  static const reviewMinuteKey = 'review_minute';
  static const dailyNewKey = 'daily_new_limit';
  static const dailyReviewKey = 'daily_review_limit';
  static const readingGoalKey = 'reading_goal_minutes';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      theme: _enum(AppThemeChoice.values, prefs.getString(themeKey), AppThemeChoice.system),
      localeCode: _locale(prefs),
      layout: _enum(
        LibraryLayoutKind.values,
        prefs.getString(layoutKey),
        LibraryLayoutKind.list,
      ),
      accent: _enum(AccentChoice.values, prefs.getString(accentKey), AccentChoice.note),
      fontScale: (prefs.getDouble(fontKey) ?? 1).clamp(0.85, 1.35).toDouble(),
      onboardingComplete: prefs.getBool(onboardingKey) ?? false,
      gatePassed: prefs.getBool(gateKey) ?? false,
      goal: _enum(LearningGoal.values, prefs.getString(goalKey), LearningGoal.both),
      reviewHour: prefs.getInt(reviewHourKey) ?? 20,
      reviewMinute: prefs.getInt(reviewMinuteKey) ?? 0,
      dailyNewLimit: prefs.getInt(dailyNewKey) ?? 10,
      dailyReviewLimit: prefs.getInt(dailyReviewKey) ?? 20,
      dailyReadingMinutes: prefs.getInt(readingGoalKey) ?? 15,
    );
  }

  Future<void> setTheme(AppThemeChoice theme) {
    state = state.copyWith(theme: theme);
    return ref.read(sharedPreferencesProvider).setString(themeKey, theme.name);
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(localeKey, code);
    await prefs.setString(CaptureLanguageController.storageKey, code);
    ref.invalidate(captureLanguageProvider);
  }

  Future<void> setLayout(LibraryLayoutKind layout) {
    state = state.copyWith(layout: layout);
    return ref.read(sharedPreferencesProvider).setString(layoutKey, layout.name);
  }

  Future<void> setAccent(AccentChoice accent) {
    state = state.copyWith(accent: accent);
    return ref.read(sharedPreferencesProvider).setString(accentKey, accent.name);
  }

  Future<void> setFontScale(double scale) {
    final next = scale.clamp(0.85, 1.35).toDouble();
    state = state.copyWith(fontScale: next);
    return ref.read(sharedPreferencesProvider).setDouble(fontKey, next);
  }

  Future<void> completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
    return ref.read(sharedPreferencesProvider).setBool(onboardingKey, true);
  }

  Future<void> setGoal(LearningGoal goal) {
    state = state.copyWith(goal: goal);
    return ref.read(sharedPreferencesProvider).setString(goalKey, goal.name);
  }

  Future<void> setReviewTime(int hour, int minute) async {
    state = state.copyWith(reviewHour: hour, reviewMinute: minute);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(reviewHourKey, hour);
    await prefs.setInt(reviewMinuteKey, minute);
  }

  Future<void> setReviewLimits({required int dailyNew, required int dailyReview}) async {
    state = state.copyWith(dailyNewLimit: dailyNew, dailyReviewLimit: dailyReview);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(dailyNewKey, dailyNew);
    await prefs.setInt(dailyReviewKey, dailyReview);
  }

  Future<void> setReadingGoal(int minutes) {
    final next = minutes.clamp(5, 180);
    state = state.copyWith(dailyReadingMinutes: next);
    return ref.read(sharedPreferencesProvider).setInt(readingGoalKey, next);
  }

  Future<void> markEntered() {
    state = state.copyWith(gatePassed: true);
    return ref.read(sharedPreferencesProvider).setBool(gateKey, true);
  }

  String _locale(SharedPreferences prefs) {
    final stored = prefs.getString(localeKey);
    if (stored != null && (stored == 'en' || stored == 'ru' || stored == 'uz')) {
      return stored;
    }
    final code = PlatformDispatcher.instance.locale.languageCode;
    if (code == 'ru' || code == 'uz') return code;
    return 'en';
  }
}

T _enum<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
