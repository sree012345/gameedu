/*
 * ----------------------------------------------------------------------------- 
 * File        : lib/widgets/buttons/small_button.dart
 * Description : Defines a small styled button extending BaseButton with preset styles.
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-03-03
 * Last Updated: 2026-03-03
 * ----------------------------------------------------------------------------- 
 * © 2026 Revolution Games Private Limited. All rights reserved.
 * ----------------------------------------------------------------------------- 
 *
 * Class       : SmallButton
 * Purpose     : Provides a compact-sized styled button with customizable
 *               text, prefix icon, and loading state.
 * ----------------------------------------------------------------------------- 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/constants/ui/size_constants.dart';
import 'package:game_edu/common/constants/ui/spacing_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/localization/cubit/language_cubit.dart';
import 'package:game_edu/core/utils/app_utils.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../base/base_button.dart';

class SmallButton extends BaseButton {
  SmallButton({
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
         height: height ?? SizeConstants.fullSmallbuttonHeight,
         backgroundColor: backgroundColor ?? AppPalette.primaryAccent,
         child: SizedBox(
           height: SizeConstants.defaultSmallbuttonHeight,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               /// Reserve loader space to prevent layout shift
               if (hasLoaderWidget)
                 SizedBox(
                   width: prefixIcon != null && !isLoading
                       ? 0
                       : SizeConstants.buttonLoaderWidgetSmall,
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
                             SizeConstants.buttonLoaderWidgetSmall,
                         child: prefixIcon,
                       ),
                       const SizedBox(width: Spacing.xs),
                     ],

                     /// TEXT
                     Flexible(
                       child: BlocBuilder<LanguageCubit, Locale>(
    builder: (context, locale) {
      final isEnglish = locale.languageCode == 'en';

      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        strutStyle: AppUtils.tightStrut,
        style:
            textStyle ??
            TextStyle(
              fontFamily: AppFonts.calibrib,
              fontSize: isEnglish
                  ? FontSizes.buttonSmall
                  : FontSizes.buttonSmall-2, // smaller for non-English scripts
              fontWeight: FontWeight.bold,
              color: isOpacityLess
                  ? AppPalette.disabledColor
                  : AppPalette.buttonTextColor,
            ),
      );
    },
  ),
                     ),
                   ],
                 ),
               ),

               /// LOADER
               if (isLoading && hasLoaderWidget) ...[
                 const SizedBox(width: Spacing.xs),
                 const SizedBox(
                   height: SizeConstants.buttonLoaderWidgetSmall,
                   width: SizeConstants.buttonLoaderWidgetSmall,
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
                       : SizeConstants.buttonLoaderWidgetSmall,
                 ),
             ],
           ),
         ),
       );
}