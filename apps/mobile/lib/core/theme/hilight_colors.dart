import 'package:flutter/material.dart';

/// Design tokens. Widgets read these instead of writing color literals.
@immutable
class HilightColors extends ThemeExtension<HilightColors> {
  const HilightColors({
    required this.background,
    required this.card,
    required this.text,
    required this.secondary,
    required this.primary,
    required this.ink,
    required this.onInk,
    required this.quote,
    required this.voice,
    required this.note,
    required this.ai,
    required this.quoteTint,
    required this.voiceTint,
    required this.noteTint,
    required this.aiTint,
    required this.accentLine,
    required this.hairline,
    required this.shadow,
    required this.scrim,
  });

  final Color background;
  final Color card;
  final Color text;
  final Color secondary;
  final Color primary;
  final Color ink;
  final Color onInk;
  final Color quote;
  final Color voice;
  final Color note;
  final Color ai;
  final Color quoteTint;
  final Color voiceTint;
  final Color noteTint;
  final Color aiTint;
  final Color accentLine;
  final Color hairline;
  final Color shadow;
  final Color scrim;

  static const double radius = 22;

  static const light = HilightColors(
    background: Color(0xFFFCFAF7),
    card: Color(0xFFFFFFFF),
    text: Color(0xFF231F1C),
    secondary: Color(0xFF7C7167),
    primary: Color(0xFF7A5A3C),
    ink: Color(0xFF231F1C),
    onInk: Color(0xFFFFFFFF),
    quote: Color(0xFFD9A441),
    voice: Color(0xFF8B6FBF),
    note: Color(0xFF7A5A3C),
    ai: Color(0xFF5B8DB8),
    quoteTint: Color(0xFFFBF3DF),
    voiceTint: Color(0xFFEFEAF8),
    noteTint: Color(0xFFF6F1EA),
    aiTint: Color(0xFFE8F0F8),
    accentLine: Color(0xFF7A5A3C),
    hairline: Color(0x0D3C2D1E),
    shadow: Color(0x0A3C2D1E),
    scrim: Color(0x661C1917),
  );

  static const dark = HilightColors(
    background: Color(0xFF141210),
    card: Color(0xFF1E1A17),
    text: Color(0xFFF6F1EB),
    secondary: Color(0xFFA89C92),
    primary: Color(0xFFC4A484),
    ink: Color(0xFFF3EEE8),
    onInk: Color(0xFF231F1C),
    quote: Color(0xFFE0B85C),
    voice: Color(0xFFB39AD4),
    note: Color(0xFFC4A484),
    ai: Color(0xFF8FB4D4),
    quoteTint: Color(0xFF3A3224),
    voiceTint: Color(0xFF2C2836),
    noteTint: Color(0xFF2A2622),
    aiTint: Color(0xFF243038),
    accentLine: Color(0xFFC4A484),
    hairline: Color(0x14F3ECE4),
    shadow: Color(0x14000000),
    scrim: Color(0xCC100E0C),
  );

  List<BoxShadow> get cardShadow => [
    BoxShadow(color: shadow, blurRadius: 30, offset: const Offset(0, 6)),
  ];

  BoxDecoration surface({double radius = radius}) {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: hairline),
      boxShadow: cardShadow,
    );
  }

  Color tintFor(Color line) {
    if (line == quote) return quoteTint;
    if (line == voice) return voiceTint;
    if (line == ai) return aiTint;
    return noteTint;
  }

  @override
  HilightColors copyWith({
    Color? background,
    Color? card,
    Color? text,
    Color? secondary,
    Color? primary,
    Color? ink,
    Color? onInk,
    Color? quote,
    Color? voice,
    Color? note,
    Color? ai,
    Color? quoteTint,
    Color? voiceTint,
    Color? noteTint,
    Color? aiTint,
    Color? accentLine,
    Color? hairline,
    Color? shadow,
    Color? scrim,
  }) {
    return HilightColors(
      background: background ?? this.background,
      card: card ?? this.card,
      text: text ?? this.text,
      secondary: secondary ?? this.secondary,
      primary: primary ?? this.primary,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      quote: quote ?? this.quote,
      voice: voice ?? this.voice,
      note: note ?? this.note,
      ai: ai ?? this.ai,
      quoteTint: quoteTint ?? this.quoteTint,
      voiceTint: voiceTint ?? this.voiceTint,
      noteTint: noteTint ?? this.noteTint,
      aiTint: aiTint ?? this.aiTint,
      accentLine: accentLine ?? this.accentLine,
      hairline: hairline ?? this.hairline,
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
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      quote: Color.lerp(quote, other.quote, t)!,
      voice: Color.lerp(voice, other.voice, t)!,
      note: Color.lerp(note, other.note, t)!,
      ai: Color.lerp(ai, other.ai, t)!,
      quoteTint: Color.lerp(quoteTint, other.quoteTint, t)!,
      voiceTint: Color.lerp(voiceTint, other.voiceTint, t)!,
      noteTint: Color.lerp(noteTint, other.noteTint, t)!,
      aiTint: Color.lerp(aiTint, other.aiTint, t)!,
      accentLine: Color.lerp(accentLine, other.accentLine, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

extension HilightColorsContext on BuildContext {
  HilightColors get hilight => Theme.of(this).extension<HilightColors>()!;
}
