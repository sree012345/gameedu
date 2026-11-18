/*
 * -----------------------------------------------------------------------------
 * File        : lib/widgets/buttons/as_icon_button.dart
 * Description : A reusable icon-only button widget with customizable icon,
 *               color, tooltip, and background. Supports icons, assets, SVGs,
 *               or network images.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-07-01
 * Last Updated: 2025-10-29
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : EsIconButton
 * Purpose     : 
 * Provides a flexible, tappable icon button for actions, supporting
 * standard icons, asset images, SVGs, or network icons.
 *
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_edu/common/constants/ui/padding_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';


class EsIconButton extends StatelessWidget {
  final IconData? icon; // optional IconData
  final String? iconUrl; // optional network image URL
  final String? assetPath; // optional asset image path (supports SVG/PNG)
  final VoidCallback onPressed; // required callback
  final Color? iconColor; // optional icon color
  final double? iconSize; // optional icon size
  final Color? backgroundColor; // optional background
  final String? tooltip; // optional tooltip
  final Key? buttonKey;
  final EdgeInsetsGeometry padding;

  const EsIconButton({
    super.key,
    this.icon,
    this.iconUrl,
    this.assetPath,
    required this.onPressed,
    this.iconColor,
    this.iconSize,
    this.backgroundColor,
    this.tooltip,
    this.buttonKey,
    this.padding = const EdgeInsets.all(PaddingConstants.small),
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;

    if (assetPath != null && assetPath!.isNotEmpty) {
      if (assetPath!.toLowerCase().endsWith('.svg')) {
        iconWidget = SvgPicture.asset(
          assetPath!,
          width: iconSize ?? 20,
          height: iconSize ?? 20,
          colorFilter: ColorFilter.mode(
            iconColor ?? AppPalette.textPrimaryColor,
            BlendMode.srcIn,
          ),
        );
      } else {
        iconWidget = Image.asset(
          assetPath!,
          width: iconSize ?? 20,
          height: iconSize ?? 20,
          color: iconColor,
        );
      }
    } else {
      iconWidget = Icon(
        icon ?? Icons.help_outline,
        size: iconSize ?? 20,
        color: iconColor ?? AppPalette.primaryAccent,
      );
    }

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppPalette.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppPalette.dividerColor, width: 1),
            ),
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}
