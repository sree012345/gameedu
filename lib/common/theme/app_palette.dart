import 'package:flutter/material.dart';

/// Defines the color palette used throughout the application.
///
/// This class contains a set of static constant colors that help maintain
/// consistency in UI design. It includes primary background colors,
/// gradient colors, border colors, and utility colors such as white,
/// grey, error indication, and transparency.

class AppPalette {
  // ───────────────────────── Existing colors (unchanged) ─────────────────────────
  static const Color primaryAccent = Color(0xFFE3FF59);
  static const Color backgroundColor = Color(0xFF0F0F0F);
  static const Color cardSurfaceColor = Color(0xFF16151B);
  static const Color elevatedSurfaceColor = Color(0xFF302E37);
  static const Color dividerColor = Color(0xFF23232B);
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFA7A6A9);
  static const Color disabledColor = Color(0xFF707173);
  static const Color buttonTextColor = Color(0xFF0F0F0F);
  static const Color menuActiveBgColor = Color(0xFF302E37);

  static const Color errorBorderColor = Color.fromRGBO(204, 17, 17, 1);
  static const Color errorText = Color(0xFFE53935);
  static const Color transparentColor = Colors.transparent;

  /// Base shimmer animation color
  static const Color shimmerBaseColor = Color(0x1AFFFFFF);

  /// Highlight shimmer animation color
  static const Color shimmerHighlightColor = Colors.white;

  /// Skeleton surface color
  static const Color shimmerSurfaceColor = Color(0x24FFFFFF);

  // ═════════════════ Game Edu (Login / Register / OTP) ═════════════════
  // Hex values are estimated from the screens, so verify against Figma.

  // ───────────────────────── Brand / Primary ─────────────────────────
  /// Main brand blue (links, active borders, icons, highlighted title words)
  static const Color primaryBlue = Color(0xFF1F5FFF);

  /// Darker blue (button gradient end, pressed state)
  static const Color primaryBlueDark = Color(0xFF1A47D6);

  /// Lighter blue (button gradient start)
  static const Color primaryBlueLight = Color(0xFF3B82F6);

  /// Cyan accent (the "Edu" in the logo)
  static const Color accentCyan = Color(0xFF22D3EE);

  /// Gold accent (graduation cap tassel)
  static const Color accentGold = Color(0xFFF5B400);

  // ───────────────────────── Backgrounds ─────────────────────────
  /// Header hero gradient (top → bottom)
  static const Color headerGradientStart = Color(0xFF0B57F0);
  static const Color headerGradientMid = Color(0xFF2F80FF);
  static const Color headerGradientEnd = Color(0xFF8FC1FF);

  /// Page background gradient behind the card (light blue fade)
  static const Color pageGradientStart = Color(0xFF8DBEFF);
  static const Color pageGradientEnd = Color(0xFFD6E6FF);

  /// White card surface holding the forms
  static const Color authCardSurfaceColor = Color(0xFFFFFFFF);

  /// Soft tinted surface (info box on OTP screen)
  static const Color infoSurfaceColor = Color(0xFFF2F6FF);

  // ───────────────────────── Text ─────────────────────────
  /// Headings & input labels (dark navy)
  static const Color authTextPrimaryColor = Color(0xFF0F1B4C);

  /// Subtitles, helper text (blue-grey)
  static const Color authTextSecondaryColor = Color(0xFF6B7A99);

  /// Placeholder / hint text inside inputs
  static const Color hintTextColor = Color(0xFF8E9BC0);

  /// Text on top of filled buttons & header
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF);

  // ───────────────────────── Inputs / Borders ─────────────────────────
  /// Default input border (light blue-grey)
  static const Color inputBorderColor = Color(0xFFD6E0F5);

  /// Focused / filled OTP box border
  static const Color inputFocusedBorderColor = primaryBlue;

  /// Input icon color
  static const Color inputIconColor = Color(0xFF1F5FFF);

  /// Divider line ("or continue with")
  static const Color authDividerColor = Color(0xFFD6E0F5);

  /// Drop-shadow / bottom lip under primary button
  static const Color buttonShadowColor = Color(0xFFCFDBFA);

  // ───────────────────────── Buttons ─────────────────────────
  static const Color authButtonTextColor = Color(0xFFFFFFFF);
  static const Color authDisabledColor = Color(0xFFB8C4E0);
  static const Color secondaryButtonBgColor = Color(0xFFFFFFFF);
  static const Color secondaryButtonTextColor = Color(0xFF0F1B4C);

  // ───────────────────────── Feedback ─────────────────────────
  /// Success (valid college tick)
  static const Color successColor = Color(0xFF16A34A);
  static const Color successBgColor = Color(0xFFDDF5E6);

  // ───────────────────────── Utility ─────────────────────────
  static const Color white = Colors.white;

  /// Translucent back-button circle on the header
  static const Color overlayWhite20 = Color(0x33FFFFFF);

  // ───────────────────────── Shimmer (light theme) ─────────────────────────
  static const Color authShimmerBaseColor = Color(0xFFE6EEFB);
  static const Color authShimmerHighlightColor = Color(0xFFF7FAFF);
  static const Color authShimmerSurfaceColor = Color(0xFFDCE6F8);

  // ───────────────────────── Gradients ─────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerGradientStart, headerGradientMid, headerGradientEnd],
  );

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [pageGradientStart, pageGradientEnd],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlueLight, primaryBlueDark],
  );
}