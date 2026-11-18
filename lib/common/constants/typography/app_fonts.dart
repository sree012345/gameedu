import 'package:flutter/material.dart';

class AppFonts {
  /// Existing Fonts
  static const String calibr = 'CALIBR';
  static const String calibrib = 'CALIBRIB';

  /// Editor Fonts
  static const String poppins = 'Poppins';
  static const String bebasNeue = 'BebasNeue';
  static const String pacifico = 'Pacifico';
  static const String oswald = 'Oswald';
  static const String playfairDisplay = 'PlayfairDisplay';

  /// Editor Fonts List
  static const List<String> editorFonts = [
    poppins,
    bebasNeue,
    pacifico,
    oswald,
    playfairDisplay,
  ];

  /// Existing
  static const TextStyle calibribRegular = TextStyle(
    fontFamily: calibrib,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle calibribMedium = TextStyle(
    fontFamily: calibrib,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle calibribBold = TextStyle(
    fontFamily: calibrib,
    fontWeight: FontWeight.w700,
  );

  /// Editor Text Styles
  static const TextStyle poppinsRegular = TextStyle(
    fontFamily: poppins,
  );

  static const TextStyle bebasNeueRegular = TextStyle(
    fontFamily: bebasNeue,
  );

  static const TextStyle pacificoRegular = TextStyle(
    fontFamily: pacifico,
  );

  static const TextStyle oswaldRegular = TextStyle(
    fontFamily: oswald,
  );

  static const TextStyle playfairDisplayRegular = TextStyle(
    fontFamily: playfairDisplay,
  );
}