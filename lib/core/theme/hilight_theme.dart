import 'package:flutter/material.dart';

import 'hilight_colors.dart';

abstract final class HilightTheme {
  static const uiFont = 'Inter';
  static const quoteFont = 'Lora';

  static ThemeData light({Color? accent}) =>
      _theme(_withAccent(HilightColors.light, accent), Brightness.light);

  static ThemeData dark({Color? accent}) =>
      _theme(_withAccent(HilightColors.dark, accent), Brightness.dark);

  static HilightColors _withAccent(HilightColors base, Color? accent) {
    if (accent == null) return base;
    return base.copyWith(primary: accent);
  }

  static ThemeData _theme(HilightColors colors, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.card,
      secondary: colors.secondary,
      onSecondary: colors.card,
      error: colors.voice,
      onError: colors.card,
      surface: colors.background,
      onSurface: colors.text,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: uiFont,
      extensions: [colors],
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: uiFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
      textTheme: base.textTheme
          .apply(
            fontFamily: uiFont,
            bodyColor: colors.text,
            displayColor: colors.text,
          )
          .copyWith(
            headlineMedium: TextStyle(
              fontFamily: quoteFont,
              fontSize: 28,
              height: 1.25,
              color: colors.text,
            ),
          ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HilightColors.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        hintStyle: TextStyle(color: colors.secondary, fontFamily: uiFont),
        labelStyle: TextStyle(color: colors.secondary, fontFamily: uiFont),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HilightColors.radius),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.card,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HilightColors.radius),
          ),
          textStyle: const TextStyle(
            fontFamily: uiFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HilightColors.radius),
          ),
          textStyle: const TextStyle(
            fontFamily: uiFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.text,
        contentTextStyle: TextStyle(color: colors.background, fontFamily: uiFont),
      ),
    );
  }

  static TextStyle quoteStyle(HilightColors colors) {
    return TextStyle(
      fontFamily: quoteFont,
      fontSize: 22,
      height: 1.45,
      color: colors.text,
    );
  }
}
