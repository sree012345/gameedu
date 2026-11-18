/*
 * -----------------------------------------------------------------------------
 * File        : lib\widgets\buttons\large_outline_button.dart
 * Description : Defines a large styled outline button extending RcOutlineButton with preset styles.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-01
 * Last Updated: 2025-12-01
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : LargeOutlineButton
 * Purpose     : Provides a large-sized, styled outline button with customizable text and loading state.
 * -----------------------------------------------------------------------------
 */

import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/constants/ui/size_constants.dart';
import 'package:game_edu/common/constants/ui/spacing_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../base/base_outline_button.dart';

class LargeOutlineButton extends BaseOutlineButton {
  LargeOutlineButton({
    super.key,
    required String text,
    TextStyle? textStyle,
    required super.onPressed,
    super.loaderWidget,
    super.isLoading = false,
    super.borderColor,
    super.foregroundColor,
    super.isOpacityLess,
    super.borderWidth,
    super.backgroundColor,
    Widget? prefixIcon,
  }) : super(
         height: SizeConstants.defaultLargebuttonHeight,
         padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
         child: SizedBox(
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               if (prefixIcon != null && !isLoading) ...[
                 SizedBox(
                   width: SizeConstants.buttonPrefixIconSideLarge,
                   child: prefixIcon,
                 ),
                 const SizedBox(width: Spacing.md),
               ],

               Text(
                 text,
                 textAlign: TextAlign.center,
                 softWrap: false,
                 overflow: TextOverflow.ellipsis,
                 maxLines: 1,
                 style:
                     textStyle ??
                     TextStyle(
                       fontFamily: AppFonts.calibrib,
                       fontSize: FontSizes.extraLarge,
                       color: foregroundColor ?? AppPalette.primaryAccent,
                       fontWeight: FontWeight.bold,
                     ),
               ),

               if (isLoading) ...[
                 const SizedBox(width: Spacing.md),
                 SizedBox(
                   height: SizeConstants.buttonLoaderWidgetMedium,
                   width: SizeConstants.buttonLoaderWidgetMedium,
                   child: LoadingIndicator(
                     indicatorType: Indicator.lineSpinFadeLoader,
                     colors: [foregroundColor ?? AppPalette.primaryAccent],
                     strokeWidth: SizeConstants.mediumStrokeWidth,
                     backgroundColor: AppPalette.transparentColor,
                     pathBackgroundColor: AppPalette.transparentColor,
                   ),
                 ),
               ],
             ],
           ),
         ),
       );
}
