/*
 * ----------------------------------------------------------------------------- 
 * File        : lib/widgets/buttons/medium_button.dart
 * Description : Defines a medium styled button extending BaseButton with preset styles.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-01
 * Last Updated: 2026-03-03
 * ----------------------------------------------------------------------------- 
 * © 2026 Revolution Games Private Limited. All rights reserved.
 * ----------------------------------------------------------------------------- 
 *
 * Class       : MediumButton
 * Purpose     : Provides a medium-sized, gradient pill button with customizable
 *               text, prefix icon, trailing arrow, and loading state.
 * ----------------------------------------------------------------------------- 
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/constants/ui/size_constants.dart';
import 'package:game_edu/common/constants/ui/spacing_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../base/base_button.dart';

class MediumButton extends BaseButton {
  MediumButton({
    super.key,
    required String text,
    TextStyle? textStyle,
    Widget? prefixIcon,
    double? prefixIconSize,
    bool showArrow = true,
    Widget? suffixIcon,
    required super.onPressed,
    super.isLoading,
    bool hasLoaderWidget = true,
    super.backgroundColor,
    Gradient? gradient,
    super.isOpacityLess,
    double? height,
  }) : super(
         height: height ?? (kIsWeb ? SizeConstants.fullMediumbuttonHeight : 52),

         /// Gradient is used by default. If a solid backgroundColor is
         /// passed, the gradient is skipped and the solid color is used.
         gradient: backgroundColor != null
             ? null
             : (gradient ?? AppPalette.primaryButtonGradient),
         foregroundColor: AppPalette.authButtonTextColor,

         /// Pill shape
         borderRadius: const BorderRadius.all(Radius.circular(100)),

         /// Pale shadow under the button
         elevation: 8,
         shadowColor: AppPalette.buttonShadowColor,

         /// Injected content
         child: SizedBox(
           height: SizeConstants.defaultMediumbuttonHeight,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               /// Reserve loader space to prevent layout shift
               if (hasLoaderWidget)
                 SizedBox(
                   width: prefixIcon != null && !isLoading
                       ? 0
                       : SizeConstants.buttonLoaderWidgetMedium,
                 ),

               /// CENTER CONTENT
               Flexible(
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     if (prefixIcon != null && !isLoading) ...[
                       SizedBox(
                         width:
                             prefixIconSize ??
                             SizeConstants.buttonLoaderWidgetMedium,
                         child: prefixIcon,
                       ),
                       const SizedBox(width: Spacing.xs),
                     ],

                     /// TEXT
                     Flexible(
                       child: Text(
                         text,
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                         softWrap: false,
                         style:
                             textStyle ??
                             TextStyle(
                               fontFamily: AppFonts.calibrib,
                               fontSize: FontSizes.medium,
                               fontWeight: FontWeight.bold,
                               color: isOpacityLess
                                   ? AppPalette.authDisabledColor
                                   : AppPalette.authButtonTextColor,
                             ),
                       ),
                     ),

                     /// TRAILING ARROW
                     if (showArrow && !isLoading) ...[
                       const SizedBox(width: Spacing.xs),
                       suffixIcon ??
                           const Icon(
                             Icons.arrow_forward_rounded,
                             size: 20,
                             color: AppPalette.authButtonTextColor,
                           ),
                     ],
                   ],
                 ),
               ),

               /// LOADER
               if (isLoading && hasLoaderWidget) ...[
                 const SizedBox(width: Spacing.sm),
                 const SizedBox(
                   height: SizeConstants.buttonLoaderWidgetMedium,
                   width: SizeConstants.buttonLoaderWidgetMedium,
                   child: LoadingIndicator(
                     indicatorType: Indicator.lineSpinFadeLoader,
                     colors: [AppPalette.authButtonTextColor],
                     strokeWidth: SizeConstants.mediumStrokeWidth,
                     backgroundColor: AppPalette.transparentColor,
                     pathBackgroundColor: AppPalette.transparentColor,
                   ),
                 ),
               ] else if (hasLoaderWidget)
                 SizedBox(
                   width: prefixIcon != null && !isLoading
                       ? 0
                       : SizeConstants.buttonLoaderWidgetMedium,
                 ),
             ],
           ),
         ),
       );
}