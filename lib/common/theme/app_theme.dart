import 'package:flutter/material.dart';
import 'package:game_edu/common/constants/typography/app_fonts.dart';

import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static final ThemeData lightThemeMode = ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.calibr,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.primaryBlue,
      primary: AppPalette.primaryBlue,
      onPrimary: AppPalette.textOnPrimaryColor,
      surface: AppPalette.authCardSurfaceColor,
      onSurface: AppPalette.authTextPrimaryColor,
      error: AppPalette.errorBorderColor,
    ),
    scaffoldBackgroundColor: AppPalette.infoSurfaceColor,
    dividerColor: AppPalette.authDividerColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.authCardSurfaceColor,
      foregroundColor: AppPalette.authTextPrimaryColor,
      surfaceTintColor: AppPalette.transparentColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.authCardSurfaceColor,
      hintStyle: const TextStyle(color: AppPalette.hintTextColor),
      enabledBorder: _border(AppPalette.inputBorderColor),
      focusedBorder: _border(AppPalette.inputFocusedBorderColor, width: 2),
      errorBorder: _border(AppPalette.errorBorderColor),
      focusedErrorBorder: _border(AppPalette.errorBorderColor, width: 2),
    ),
  );
}