/*
 * -----------------------------------------------------------------------------
 * File        : lib\widgets\buttons\small_outline_button.dart
 * Description : Defines a medium styled outline button extending RcOutlineButton with preset styles.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-01
 * Last Updated: 2025-12-01
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : SmallOutlineButton
 * Purpose     : Provides a medium-sized, styled outline button with customizable text and loading state.
 * -----------------------------------------------------------------------------
 */

import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/constants/ui/size_constants.dart';
import 'package:game_edu/common/constants/ui/spacing_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../base/base_outline_button.dart';

class SmallOutlineButton extends BaseOutlineButton {
  SmallOutlineButton({
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
    super.disableSplash,
    super.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool? handleOverflow,
  }) : super(
         height: SizeConstants.fullSmallbuttonHeight,
         child: SizedBox(
           child: Center(
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 if (prefixIcon != null && !isLoading) ...[
                   SizedBox(
                     width: SizeConstants.buttonLoaderWidgetMedium,
                     child: prefixIcon,
                   ),
                   const SizedBox(width: Spacing.sm),
                 ],
                 if (handleOverflow == true) ...[
                   Flexible(
                     child: Text(
                       text,
                       textAlign: TextAlign.center,
                       softWrap: false,
                       overflow: TextOverflow.ellipsis,
                       maxLines: 1,
                       strutStyle: AppUtils.tightStrut,
                       style:
                           textStyle ??
                           TextStyle(
                             fontSize: FontSizes.buttonSmall,
                             color: foregroundColor ?? AppPalette.primaryAccent,
                             fontWeight: FontWeight.normal,
                             fontFamily: AppFonts.calibrib,
                           ),
                     ),
                   ),
                 ] else ...[
                   Text(
                     text,
                     textAlign: TextAlign.center,
                     softWrap: false,
                     overflow: TextOverflow.ellipsis,
                     maxLines: 1,
                     strutStyle: AppUtils.tightStrut,
                     style:
                         textStyle ??
                         TextStyle(
                           fontSize: FontSizes.buttonSmall,
                           color: foregroundColor ?? AppPalette.primaryAccent,
                           fontWeight: FontWeight.normal,
                           fontFamily: AppFonts.calibrib,
                         ),
                   ),
                 ],

                 if (isLoading) ...[
                   const SizedBox(width: Spacing.sm),
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
                 ] else if (suffixIcon != null) ...[
                   const SizedBox(width: Spacing.sm),
                   SizedBox(
                     width: SizeConstants.buttonLoaderWidgetMedium,
                     child: suffixIcon,
                   ),
                 ],
               ],
             ),
           ),
         ),
       );

  Widget handleOverflow(bool isHandleOverflow, Widget child) {
    return isHandleOverflow == true ? Flexible(child: child) : child;
  }
}
