import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  //The purpose of the below code is to define a custom border style for text input fields (such as TextField or TextFormField) in a Flutter application.

  //Uses `OutlineInputBorder` to create a bordered input field.
  // ignore: unused_element
  static _border([Color color = AppPalette.errorBorderColor]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      );

  // static final lightThemeMode = ThemeData.light().copyWith(
  //   scaffoldBackgroundColor: AppPalette.primaryColor,

  //   primaryColor: AppPalette.primaryColor,
  //   focusColor: AppPalette.focusColor,
  //   appBarTheme: AppBarTheme(
  //     backgroundColor: AppPalette.backgroundColor,
  //   ),
   
  //   chipTheme: ChipThemeData(
  //     color: WidgetStatePropertyAll(
  //       AppPalette.backgroundColor,
  //     ),
  //     side: BorderSide.none,
  //   ),

  //   //By adding inputDecorationTheme inside ThemeData, every TextField and TextFormField automatically inherits this styling, reducing redundant code.
  //   inputDecorationTheme: InputDecorationTheme(
  //     contentPadding: EdgeInsets.all(27), // Adds padding inside the text field.
  //     enabledBorder:
  //         _border(), // Applies a custom border when the field is not focused.
  //     focusedBorder: _border(AppPalette
  //         .gradient2), // Applies the same custom border when the field is focused.
  //     errorBorder: _border(AppPalette.errorColor),
  //   ),
  // );
}
