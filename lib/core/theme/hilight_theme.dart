import 'package:flutter/material.dart';

import 'hilight_colors.dart';

abstract final class HilightTheme {
  static const uiFont = 'Inter';
  static const quoteFont = 'Lora';
  static const motion = Duration(milliseconds: 250);

  static ThemeData light({Color? accent}) =>
      _theme(_withAccent(HilightColors.light, accent), Brightness.light);

  static ThemeData dark({Color? accent}) =>
      _theme(_withAccent(HilightColors.dark, accent), Brightness.dark);

  /// Accent stays a thin line. It does not recolor buttons or large surfaces.
  static HilightColors _withAccent(HilightColors base, Color? accent) {
    if (accent == null) return base;
    return base.copyWith(accentLine: accent);
  }

  static ThemeData _theme(HilightColors colors, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.ink,
      onPrimary: colors.onInk,
      secondary: colors.primary,
      onSecondary: colors.card,
      error: const Color(0xFF9A4A3A),
      onError: colors.card,
      surface: colors.background,
      onSurface: colors.text,
    );
    final label = TextStyle(
      fontFamily: uiFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: colors.secondary,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: uiFont,
      splashFactory: InkRipple.splashFactory,
      extensions: [colors],
    );
    final pill = const StadiumBorder();
    final buttonText = TextStyle(
      fontFamily: uiFont,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: colors.onInk,
    );
    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _GentleTransition(),
          TargetPlatform.iOS: _GentleTransition(),
          TargetPlatform.macOS: _GentleTransition(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: colors.background,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: uiFont,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colors.text,
        ),
      ),
      textTheme: base.textTheme
          .apply(fontFamily: uiFont, bodyColor: colors.text, displayColor: colors.text)
          .copyWith(
            headlineMedium: TextStyle(
              fontFamily: uiFont,
              fontSize: 28,
              height: 1.25,
              fontWeight: FontWeight.w500,
              color: colors.text,
            ),
            titleMedium: TextStyle(
              fontFamily: uiFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.text,
            ),
            bodyLarge: TextStyle(
              fontFamily: uiFont,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: colors.text,
            ),
            bodyMedium: TextStyle(
              fontFamily: uiFont,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: colors.text,
            ),
            labelLarge: TextStyle(
              fontFamily: uiFont,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.text,
            ),
          ),
      dividerTheme: const DividerThemeData(color: Colors.transparent, thickness: 0, space: 0),
      listTileTheme: ListTileThemeData(
        iconColor: colors.secondary,
        textColor: colors.text,
        titleTextStyle: TextStyle(
          fontFamily: uiFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colors.text,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: uiFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colors.secondary,
        ),
        minVerticalPadding: 16,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HilightColors.radius),
          side: BorderSide(color: colors.hairline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.card,
        selectedColor: colors.card,
        disabledColor: colors.card,
        side: BorderSide(color: colors.hairline),
        labelStyle: TextStyle(
          fontFamily: uiFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colors.text,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: uiFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: pill,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        hintStyle: label,
        labelStyle: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.accentLine.withValues(alpha: 0.55)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.ink,
          foregroundColor: colors.onInk,
          disabledBackgroundColor: colors.ink.withValues(alpha: 0.35),
          disabledForegroundColor: colors.onInk.withValues(alpha: 0.7),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(48, 48),
          textStyle: TextStyle(
            fontFamily: uiFont,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.card,
          foregroundColor: colors.text,
          elevation: 0,
          side: BorderSide(color: colors.hairline),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: pill,
          textStyle: buttonText.copyWith(color: colors.text),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.text,
          minimumSize: const Size(48, 48),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accentLine,
        inactiveTrackColor: colors.hairline,
        thumbColor: colors.accentLine,
        overlayColor: colors.accentLine.withValues(alpha: 0.12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.accentLine),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HilightColors.radius),
          side: BorderSide(color: colors.hairline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(HilightColors.radius)),
          side: BorderSide(color: colors.hairline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.ink,
        contentTextStyle: TextStyle(color: colors.onInk, fontFamily: uiFont, fontSize: 15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static TextStyle quoteStyle(HilightColors colors) {
    return TextStyle(
      fontFamily: quoteFont,
      fontSize: 22,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: colors.text,
    );
  }
}

class _GentleTransition extends PageTransitionsBuilder {
  const _GentleTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}
