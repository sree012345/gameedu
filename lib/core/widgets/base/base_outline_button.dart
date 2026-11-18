/*
 * -----------------------------------------------------------------------------
 * File        : lib\widgets\base\rr_outline_button.dart
 * Description : AS Outline Button super class for button customization
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-01
 * Last Updated: 2025-12-01
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : RrOutlineButton
 * Purpose     : Provides a responsive Outline Button Widget for all resolutions
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';


class BaseOutlineButton extends StatelessWidget {
  final String? text;
  final bool noIcon;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double? height;
  final MainAxisAlignment? contentAlignment;
  final double? iconSize;
  final TextStyle? textStyle;
  final bool? enabled;
  final bool isLoading;
  final Widget? loaderWidget;
  final Widget? child;
  final bool? isOpacityLess;
  final Size? minimumSize;
  final MaterialTapTargetSize? tapTargetSize;
  final double? borderWidth;
  final Color? backgroundColor;
  final bool disableSplash;

  const BaseOutlineButton({
    super.key,
    this.text,
    required this.onPressed,
    this.noIcon = false,
    this.disableSplash = false,
    this.icon,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.width,
    this.height,
    this.contentAlignment,
    this.iconSize,
    this.textStyle,
    this.enabled,
    this.isLoading = false,
    this.loaderWidget,
    this.child,
    this.minimumSize,
    this.tapTargetSize,
    this.isOpacityLess,
    this.borderWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppPalette.primaryAccent;
    final effectiveForeground = foregroundColor ?? AppPalette.primaryAccent;
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    final effectiveFontSize = fontSize ?? 14;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(10);
    final effectiveContentAlignment =
        contentAlignment ?? MainAxisAlignment.center;
    final effectiveIconSize = iconSize ?? effectiveFontSize;

    return SizedBox(
      width: width,
      height: height,
      child: Opacity(
        opacity: isOpacityLess ?? false ? 0.5 : 1,
        child: OutlinedButton(
          onPressed: enabled == false ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveForeground,
            backgroundColor: backgroundColor,
            padding: effectivePadding,
            minimumSize: minimumSize,
            tapTargetSize: tapTargetSize,
            side: BorderSide(
              color: effectiveBorderColor,
              width: borderWidth ?? 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
            splashFactory: disableSplash ? NoSplash.splashFactory : null,
          ),
          child:
              child ??
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: effectiveContentAlignment,
                children: [
                  if (!noIcon && icon != null)
                    Icon(
                      icon,
                      size: effectiveIconSize,
                      color: effectiveForeground,
                    ),
                  if (!noIcon && icon != null) const SizedBox(width: 8),
                  if (!isLoading)
                    Text(
                      text ?? '',
                      style:
                          textStyle ??
                          TextStyle(
                            fontSize: effectiveFontSize,
                            color: effectiveForeground,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  if (isLoading) loaderWidget ?? const SizedBox.shrink(),
                ],
              ),
        ),
      ),
    );
  }
}
