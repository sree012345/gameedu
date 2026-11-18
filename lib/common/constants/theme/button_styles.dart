import 'package:flutter/material.dart';
import 'color_constants.dart';
import '../ui/radius_constants.dart';

/// ---------------------------------------------------------------------------
/// [ButtonStyles]
/// ---------------------------------------------------------------------------
/// Centralized styles for buttons throughout the application.
/// Use this to maintain visual consistency across all button components.
/// ---------------------------------------------------------------------------

class ButtonStyles {
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      vertical: 14.0,
      horizontal: 24.0,
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RadiusConstants.medium),
    ),
  );

  static final ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(
      vertical: 14.0,
      horizontal: 24.0,
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RadiusConstants.medium),
    ),
  );

  static final ButtonStyle danger = ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RadiusConstants.small),
    ),
  );
}
