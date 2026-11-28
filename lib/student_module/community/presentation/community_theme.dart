import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';


/// The Community screens use your app's light blue theme (AppPalette), the
/// same look as your Class screen: flat blue app bar, white page, bordered
/// rounded cards, dark navy headings and blue buttons.
class CommunityColors {
  CommunityColors._();

  static const Color primary = AppPalette.primaryBlue;
  static const Color primaryDark = AppPalette.primaryBlueDark;
  static const Color primaryLight = AppPalette.primaryBlueLight;

  /// Page background (white).
  static const Color background = AppPalette.white;

  /// Soft tinted fill: received bubbles, inputs, info boxes.
  static const Color soft = AppPalette.infoSurfaceColor;

  static const Color title = AppPalette.authTextPrimaryColor;
  static const Color subtitle = AppPalette.authTextSecondaryColor;
  static const Color hint = AppPalette.hintTextColor;

  static const Color border = AppPalette.inputBorderColor;
  static const Color divider = AppPalette.authDividerColor;

  static const Color online = AppPalette.successColor;
  static const Color danger = AppPalette.errorText;
  static const Color onPrimary = AppPalette.textOnPrimaryColor;
  static const Color overlay = AppPalette.overlayWhite20;
}

const LinearGradient communityGradient = AppPalette.primaryButtonGradient;

/// Thin light-blue outline used on cards (instead of a shadow).
const Border communityBorder = Border.fromBorderSide(
  BorderSide(color: CommunityColors.border),
);

/// Cards are flat with a border, so there is no shadow.
const List<BoxShadow> communityCardShadow = <BoxShadow>[];
