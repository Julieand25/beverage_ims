import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color text;
  final Color card;
  final Color gray;
  final Color border;
  final Color inputBg;
  final Color subtleGreen;
  final Color subtleRed;
  final Color subtleBlue;
  final Color subtlePurple;

  const AppColors({
    required this.background,
    required this.text,
    required this.card,
    required this.gray,
    required this.border,
    required this.inputBg,
    required this.subtleGreen,
    required this.subtleRed,
    required this.subtleBlue,
    required this.subtlePurple,
  });

  static const light = AppColors(
    background: Color(0xFFE8F4FD),
    text: Color(0xFF2C3E50),
    card: Colors.white,
    gray: Color(0xFF9E9E9E),
    border: Color(0xFFEEEEEE),
    inputBg: Color(0xFFFAFAFA),
    subtleGreen: Color(0xFFEAF5EA),
    subtleRed: Color(0xFFFDF0F0),
    subtleBlue: Color(0xFFF0F6FF),
    subtlePurple: Color(0xFFFBF0F9),
  );

  static const dark = AppColors(
    background: Color(0xFF1A1A2E),
    text: Color(0xFFE0E0E0),
    card: Color(0xFF2D2D44),
    gray: Color(0xFF9E9E9E),
    border: Color(0xFF3D3D5C),
    inputBg: Color(0xFF252540),
    subtleGreen: Color(0xFF1B3A1B),
    subtleRed: Color(0xFF3A1B1B),
    subtleBlue: Color(0xFF1B2B3A),
    subtlePurple: Color(0xFF2E1B2E),
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? background,
    Color? text,
    Color? card,
    Color? gray,
    Color? border,
    Color? inputBg,
    Color? subtleGreen,
    Color? subtleRed,
    Color? subtleBlue,
    Color? subtlePurple,
  }) {
    return AppColors(
      background: background ?? this.background,
      text: text ?? this.text,
      card: card ?? this.card,
      gray: gray ?? this.gray,
      border: border ?? this.border,
      inputBg: inputBg ?? this.inputBg,
      subtleGreen: subtleGreen ?? this.subtleGreen,
      subtleRed: subtleRed ?? this.subtleRed,
      subtleBlue: subtleBlue ?? this.subtleBlue,
      subtlePurple: subtlePurple ?? this.subtlePurple,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      card: Color.lerp(card, other.card, t)!,
      gray: Color.lerp(gray, other.gray, t)!,
      border: Color.lerp(border, other.border, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
      subtleGreen: Color.lerp(subtleGreen, other.subtleGreen, t)!,
      subtleRed: Color.lerp(subtleRed, other.subtleRed, t)!,
      subtleBlue: Color.lerp(subtleBlue, other.subtleBlue, t)!,
      subtlePurple: Color.lerp(subtlePurple, other.subtlePurple, t)!,
    );
  }
}
