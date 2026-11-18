/*
 * -----------------------------------------------------------------------------
 * File        : lib\core\widgets\base\no_internet_view.dart
 * Description : NoInternetView - handles core functionality
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-04-28
 * Last Updated: 2026-04-28
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : NoInternetView
 * Purpose     : Manages NoInternetView operations within the module
 * -----------------------------------------------------------------------------
 */

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const NoInternetView({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /// 📱 Basic scaling factors
    final isMobile = size.width < 600;

    final iconSize = isMobile ? size.width * 0.25 : size.width * 0.12;
    final fontSize = isMobile ? size.width * 0.035 : size.width * 0.015;

    /// 🎯 Keep button FIXED (as you wanted)
    const buttonWidth = 175.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🌐 Icon
          Icon(
            Icons.wifi_off,
            size: iconSize.clamp(80, 160), // prevents stupidity scaling
            color: Colors.white,
          ),

          const SizedBox(height: 16),

          /// 📝 Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
            child: Text(
              message ?? 'dashboard.network.no_internet'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize.clamp(12, 18),
                color: AppPalette.textPrimaryColor,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔁 Button (hardcoded width, because you insisted)
          SizedBox(
            width: buttonWidth,
            child: MediumButton(
              text: 'dashboard.network.retry'.tr(),
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
