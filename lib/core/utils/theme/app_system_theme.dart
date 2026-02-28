import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSystemTheme extends ThemeExtension<AppSystemTheme> {
  final SystemUiOverlayStyle systemOverlayStyle;

  const AppSystemTheme({required this.systemOverlayStyle});

  @override
  AppSystemTheme copyWith({SystemUiOverlayStyle? systemOverlayStyle}) {
    return AppSystemTheme(
      systemOverlayStyle: systemOverlayStyle ?? this.systemOverlayStyle,
    );
  }

  @override
  AppSystemTheme lerp(ThemeExtension<AppSystemTheme>? other, double t) {
    if (other is! AppSystemTheme) return this;
    return this; // overlay style doesn’t need interpolation
  }
}