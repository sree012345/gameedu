import 'package:flutter/material.dart';
import 'font_constants.dart';
import '../theme/color_constants.dart';

/// ---------------------------------------------------------------------------
/// [TextStyles]
/// ---------------------------------------------------------------------------
/// Defines reusable TextStyles with consistent font family, size, weight,
/// and color. Extend or override as needed at the widget level.
/// ---------------------------------------------------------------------------

class TextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeights.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeights.medium,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeights.regular,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeights.medium,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeights.light,
    color: AppColors.textSecondary,
  );

  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeights.regular,
    color: AppColors.error,
  );
}
