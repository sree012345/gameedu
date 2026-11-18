/*
 * ----------------------------------------------------------------------------- 
 * File        : lib/widgets/base/base_button.dart
 * Description : Core reusable button widget providing full customization
 *               for styling, layout, interaction, and loading states.
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-03-03
 * Last Updated: 2026-03-03
 * ----------------------------------------------------------------------------- 
 * © 2026 Revolution Games Private Limited. All rights reserved.
 * ----------------------------------------------------------------------------- 
 *
 * Class       : BaseButton
 * Purpose     : Serves as the foundational button component for the app.
 *               All sized and styled buttons (SmallButton, MediumButton,
 *               LargeButton, etc.) should extend this widget.
 *
 * Features    :
 *               - Disabled & loading state handling
 *               - Customizable dimensions
 *               - Border & border radius control
 *               - Gradient & solid background support
 *               - Elevation & shadow customization
 *               - Opacity management
 *               - Full child injection
 * ----------------------------------------------------------------------------- 
 */

import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

class BaseButton extends StatelessWidget {
  /// Callback executed when button is pressed.
  final VoidCallback? onPressed;

  /// Child widget injected by extending buttons.
  final Widget child;

  /// Width of the button. Defaults to full width.
  final double? width;

  /// Height of the button. Required for layout consistency.
  final double height;

  /// Internal padding of the button.
  final EdgeInsetsGeometry? padding;

  /// Background color for solid buttons.
  final Color? backgroundColor;

  /// Optional gradient background.
  final Gradient? gradient;

  /// Foreground (text/icon) color.
  final Color? foregroundColor;

  /// Disabled background color.
  final Color? disabledColor;

  /// Border radius for button shape.
  final BorderRadiusGeometry? borderRadius;

  /// Border style for outlined buttons.
  final BorderSide? borderSide;

  /// Elevation of the button.
  final double elevation;

  /// Shadow color for elevated buttons.
  final Color? shadowColor;

  /// Indicates loading state.
  /// Blocks interaction when true.
  final bool isLoading;

  /// Reduces opacity when true.
  final bool isOpacityLess;

  /// Minimum size constraint override.
  final Size? minimumSize;

  /// Tap target size control.
  final MaterialTapTargetSize? tapTargetSize;

  /// Mouse cursor override (for desktop/web).
  final MouseCursor? mouseCursor;

  const BaseButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.height,
    this.width,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.foregroundColor,
    this.disabledColor,
    this.borderRadius,
    this.borderSide,
    this.elevation = 0,
    this.shadowColor,
    this.isLoading = false,
    this.isOpacityLess = false,
    this.minimumSize,
    this.tapTargetSize,
    this.mouseCursor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final bool isBlocked = isDisabled || isLoading;

    final BorderRadius effectiveRadius =
        (borderRadius as BorderRadius?) ?? BorderRadius.circular(10);

    return Opacity(
      opacity: (isDisabled || isOpacityLess) ? 0.6 : 1,
      child: MouseRegion(
        cursor:
            mouseCursor ??
            (isBlocked ? SystemMouseCursors.basic : SystemMouseCursors.click),
        child: SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null
                  ? (isDisabled
                        ? (disabledColor ?? AppPalette.disabledColor)
                        : backgroundColor)
                  : null,
              borderRadius: effectiveRadius,
              border: borderSide != null
                  ? Border.fromBorderSide(borderSide!)
                  : null,
              boxShadow: elevation > 0
                  ? [
                      BoxShadow(
                        color: shadowColor ?? Colors.black26,
                        blurRadius: elevation,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: isBlocked ? null : onPressed,
                borderRadius: effectiveRadius,
                child: Container(
                  padding:
                      padding ?? const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  constraints: minimumSize != null
                      ? BoxConstraints(
                          minWidth: minimumSize!.width,
                          minHeight: minimumSize!.height,
                        )
                      : null,

                  /// Apply foreground color automatically
                  child: IconTheme(
                    data: IconThemeData(
                      color: foregroundColor ?? AppPalette.buttonTextColor,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: foregroundColor ?? AppPalette.buttonTextColor,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
