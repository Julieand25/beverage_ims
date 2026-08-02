import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color text;
  final Color card;
  final Color gray;

  const AppColors({
    required this.background,
    required this.text,
    required this.card,
    required this.gray,
  });

  static const light = AppColors(
    background: Color(0xFFF9F9F9),
    text: Color(0xFF2C3E50),
    card: Colors.white,
    gray: Color(0xFF9E9E9E),
  );

  static const dark = AppColors(
    background: Color(0xFF1A1A2E),
    text: Color(0xFFE0E0E0),
    card: Color(0xFF2D2D44),
    gray: Color(0xFF9E9E9E),
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? background,
    Color? text,
    Color? card,
    Color? gray,
  }) {
    return AppColors(
      background: background ?? this.background,
      text: text ?? this.text,
      card: card ?? this.card,
      gray: gray ?? this.gray,
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
    );
  }
}
