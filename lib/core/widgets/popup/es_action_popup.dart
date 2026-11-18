/*
 * -----------------------------------------------------------------------------
 * File        : lib\core\widgets\popup\es_action_popup.dart
 * Description : EsActionPopup - handles core functionality
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-04-24
 * Last Updated: 2026-04-24
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : EsActionPopup
 * Purpose     : Manages EsActionPopup operations overall the module
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/constants/ui/spacing_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/responsive/responsive_sizes.dart';
import 'package:game_edu/core/widgets/base/card_container.dart';
import 'package:game_edu/core/widgets/buttons/large_button.dart';
import 'package:game_edu/core/widgets/buttons/large_outline_button.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';
import 'package:game_edu/core/widgets/buttons/medium_outline_button.dart';
import 'package:game_edu/core/widgets/buttons/small_button.dart';
import 'package:game_edu/core/widgets/buttons/small_outline_button.dart';

class EsActionPopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final ResponsiveSizes device;
  final String? leftButtonText;
  final VoidCallback? onLeftTap;
  final String rightButtonText;
  final VoidCallback onRightTap;

  final Color? rightButtonColor;

  final double? width;
  final bool barrierDismissible;
  final bool? hasLoaderWidget;
  final bool? isLoading;


  const EsActionPopup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.device,
    this.leftButtonText,
    this.onLeftTap,
    required this.rightButtonText,
    required this.onRightTap,
    this.rightButtonColor,
    this.width,
    this.barrierDismissible = false,
    this.hasLoaderWidget,
    this.isLoading = false,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required ResponsiveSizes device,
    required String rightButtonText,
    String? leftButtonText,
    VoidCallback? onLeftTap,
    required VoidCallback onRightTap,
    Color? rightButtonColor,
    double? width,
    bool barrierDismissible = false,
    bool hasLoaderWidget = false,
    bool isLoading = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: true,
      builder: (_) => EsActionPopup(
        device: device,
        title: title,
        subtitle: subtitle,
        leftButtonText: leftButtonText,
        rightButtonText: rightButtonText,
        onLeftTap: onLeftTap,
        onRightTap: onRightTap,
        rightButtonColor: rightButtonColor,
        width: width,
        barrierDismissible: barrierDismissible,
        hasLoaderWidget: hasLoaderWidget,
        isLoading: isLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppPalette.cardSurfaceColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPalette.dividerColor),
      ),
      child: CardContainer(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width ?? 350),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.calibrib,
                    fontSize: FontSizes.large,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textPrimaryColor,
                  ),
                ),

                const SizedBox(height: Spacing.sm),

                /// SUBTITLE
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: AppFonts.calibrib,
                    fontSize: FontSizes.medium,
                    color: AppPalette.textSecondaryColor,
                  ),
                ),

                const SizedBox(height: 60),

                /// BUTTONS
                buildActionButtons(context, device, hasLoaderWidget??false, isLoading??false),
              ],    
            ),
          ),
        ),
      ),
    );
  }

  Widget buildActionButtons(BuildContext context, ResponsiveSizes device , bool hasLoaderWidget , bool isLoading) {
    Widget buildLeft() {
      switch (device) {
        case ResponsiveSizes.mobile:
          return SmallOutlineButton(
            text: leftButtonText!,
            onPressed: onLeftTap!,
          );
        case ResponsiveSizes.ultraHD4K:
          return LargeOutlineButton(
            text: leftButtonText!,
            onPressed: onLeftTap!,
          );
        default:
          return MediumOutlineButton(
            text: leftButtonText!,
            onPressed: onLeftTap!,
          );
      }
    }

    Widget buildRight() {
      switch (device) {
        case ResponsiveSizes.mobile:
          return SmallButton(
            hasLoaderWidget: hasLoaderWidget,
            isLoading: isLoading,
            text: rightButtonText,
            backgroundColor: rightButtonColor ?? AppPalette.primaryAccent,
            onPressed: onRightTap,
          );
        case ResponsiveSizes.ultraHD4K:
          return LargeButton(
            hasLoaderWidget: hasLoaderWidget,
            isLoading: isLoading,
            text: rightButtonText,
            backgroundColor: rightButtonColor ?? AppPalette.primaryAccent,
            onPressed: onRightTap,
          );
        default:
          return MediumButton(
            hasLoaderWidget: hasLoaderWidget,
            isLoading: isLoading,
            text: rightButtonText,
            backgroundColor: rightButtonColor ?? AppPalette.primaryAccent,
            onPressed: onRightTap,
          );
      }
    }

    final hasLeft = leftButtonText != null && onLeftTap != null;

    return Row(
      children: [
        if (hasLeft) ...[
          Expanded(child: buildLeft()),
          const SizedBox(width: Spacing.sm),
        ],
        Expanded(child: buildRight()),
      ],
    );
  }
}
