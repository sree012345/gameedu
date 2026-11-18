import 'package:flutter/material.dart';
import 'package:game_edu/common/constants/theme/button_styles.dart';
import 'color_constants.dart';
import '../typography/text_styles.dart';

/// ---------------------------------------------------------------------------
/// [ThemeConstants]
/// ---------------------------------------------------------------------------
/// Provides centralized ThemeData for light and dark modes.
/// Extend or override specific components like input, cards, etc.
/// ---------------------------------------------------------------------------

class ThemeConstants {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyles.heading,
        bodyLarge: TextStyles.body,
        labelLarge: TextStyles.button,
        bodySmall: TextStyles.caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyles.primary,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyles.secondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(
        displayLarge: TextStyles.heading,
        bodyLarge: TextStyles.body,
        labelLarge: TextStyles.button,
        bodySmall: TextStyles.caption,
      ),
    );
  }
}
