import 'package:flutter/material.dart';

/// Design tokens from the HiLight rules. Widgets read these instead of
/// writing color literals.
@immutable
class HilightColors extends ThemeExtension<HilightColors> {
  const HilightColors({
    required this.background,
    required this.card,
    required this.text,
    required this.secondary,
    required this.primary,
    required this.quote,
    required this.voice,
    required this.note,
    required this.ai,
    required this.shadow,
    required this.scrim,
  });

  final Color background;
  final Color card;
  final Color text;
  final Color secondary;
  final Color primary;
  final Color quote;
  final Color voice;
  final Color note;
  final Color ai;
  final Color shadow;
  final Color scrim;

  static const double radius = 22;

  static const light = HilightColors(
    background: Color(0xFFF4EFE8),
    card: Color(0xFFFBF8F3),
    text: Color(0xFF2B2622),
    secondary: Color(0xFF8A7F74),
    primary: Color(0xFF6B4A2F),
    quote: Color(0xFFD9A441),
    voice: Color(0xFF8B6FBF),
    note: Color(0xFF6B4A2F),
    ai: Color(0xFF5B8DB8),
    shadow: Color(0x1A2B2622),
    scrim: Color(0x99000000),
  );

  static const dark = HilightColors(
    background: Color(0xFF1C1917),
    card: Color(0xFF26221F),
    text: Color(0xFFF1EBE3),
    secondary: Color(0xFF8A7F74),
    primary: Color(0xFF6B4A2F),
    quote: Color(0xFFD9A441),
    voice: Color(0xFF8B6FBF),
    note: Color(0xFF6B4A2F),
    ai: Color(0xFF5B8DB8),
    shadow: Color(0x66000000),
    scrim: Color(0xCC000000),
  );

  List<BoxShadow> get cardShadow => [
    BoxShadow(color: shadow, blurRadius: 18, offset: const Offset(0, 8)),
  ];

  @override
  HilightColors copyWith({
    Color? background,
    Color? card,
    Color? text,
    Color? secondary,
    Color? primary,
    Color? quote,
    Color? voice,
    Color? note,
    Color? ai,
    Color? shadow,
    Color? scrim,
  }) {
    return HilightColors(
      background: background ?? this.background,
      card: card ?? this.card,
      text: text ?? this.text,
      secondary: secondary ?? this.secondary,
      primary: primary ?? this.primary,
      quote: quote ?? this.quote,
      voice: voice ?? this.voice,
      note: note ?? this.note,
      ai: ai ?? this.ai,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  HilightColors lerp(ThemeExtension<HilightColors>? other, double t) {
    if (other is! HilightColors) return this;
    return HilightColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      text: Color.lerp(text, other.text, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      quote: Color.lerp(quote, other.quote, t)!,
      voice: Color.lerp(voice, other.voice, t)!,
      note: Color.lerp(note, other.note, t)!,
      ai: Color.lerp(ai, other.ai, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

extension HilightColorsContext on BuildContext {
  HilightColors get hilight => Theme.of(this).extension<HilightColors>()!;
}
