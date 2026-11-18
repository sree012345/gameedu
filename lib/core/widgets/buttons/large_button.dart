/*
 * ----------------------------------------------------------------------------- 
 * File        : lib/widgets/buttons/large_button.dart
 * Description : Defines a large styled button extending BaseButton with preset styles.
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-03-03
 * Last Updated: 2026-03-03
 * ----------------------------------------------------------------------------- 
 * © 2026 Revolution Games Private Limited. All rights reserved.
 * ----------------------------------------------------------------------------- 
 *
 * Class       : LargeButton
 * Purpose     : Provides a large-sized styled button with customizable
 *               text, prefix icon, and loading state.
 * ----------------------------------------------------------------------------- 
 */

import 'package:flutter/material.dart';
import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/constants/ui/size_constants.dart';
import 'package:game_edu/common/constants/ui/spacing_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../base/base_button.dart';

class LargeButton extends BaseButton {
  LargeButton({
    super.key,
    required String text,
    TextStyle? textStyle,
    Widget? prefixIcon,
    double? prefixIconSize,
    required super.onPressed,
    super.isLoading = false,
    bool hasLoaderWidget = true,
    Color? backgroundColor,
    super.isOpacityLess = false,
    double? height,
  }) : super(
         height: height ?? SizeConstants.defaultUltrabuttonHeight,
         backgroundColor: backgroundColor ?? AppPalette.primaryAccent,
         child: SizedBox(
           height: SizeConstants.defaultUltrabuttonHeight,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               /// Reserve loader space to prevent layout shift
               if (hasLoaderWidget)
                 SizedBox(
                   width: prefixIcon != null && !isLoading
                       ? 0
                       : SizeConstants.buttonLoaderWidgetLarge,
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
                             SizeConstants.buttonLoaderWidgetLarge,
                         child: prefixIcon,
                       ),
                       const SizedBox(width: Spacing.sm),
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
                               fontSize: FontSizes.extraLarge,
                               fontWeight: FontWeight.bold,
                               color: isOpacityLess
                                   ? AppPalette.disabledColor
                                   : AppPalette.buttonTextColor,
                             ),
                       ),
                     ),
                   ],
                 ),
               ),

               /// LOADER
               if (isLoading && hasLoaderWidget) ...[
                 const SizedBox(width: Spacing.sm),
                 const SizedBox(
                   height: SizeConstants.buttonLoaderWidgetLarge,
                   width: SizeConstants.buttonLoaderWidgetLarge,
                   child: LoadingIndicator(
                     indicatorType: Indicator.lineSpinFadeLoader,
                     colors: [AppPalette.buttonTextColor],
                     strokeWidth: SizeConstants.mediumStrokeWidth,
                     backgroundColor: AppPalette.transparentColor,
                     pathBackgroundColor: AppPalette.transparentColor,
                   ),
                 ),
               ] else if (hasLoaderWidget)
                 SizedBox(
                   width: prefixIcon != null && !isLoading
                       ? 0
                       : SizeConstants.buttonLoaderWidgetLarge,
                 ),
             ],
           ),
         ),
       );
}
