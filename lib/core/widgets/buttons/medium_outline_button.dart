
/*
 * -----------------------------------------------------------------------------
 * File        : lib\widgets\buttons\medium_outline_button.dart
 * Description : Defines a medium styled outline button extending RcOutlineButton with preset styles.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-01
 * Last Updated: 2025-12-01
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : MediumOutlineButton
 * Purpose     : Provides a medium-sized, styled outline button with customizable text and loading state.
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/constants/ui/size_constants.dart';
import 'package:game_edu/common/constants/ui/spacing_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/localization/cubit/language_cubit.dart';
import 'package:game_edu/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import '../base/base_outline_button.dart';

class MediumOutlineButton extends BaseOutlineButton {
  MediumOutlineButton({
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
    Widget? prefixIcon,
    Widget? suffixIcon,
    FontWeight? fontWeight,
    bool? handleOverflow,
  }) : super(
         height: (kIsWeb ? SizeConstants.fullMediumbuttonHeight : 43),
         child: SizedBox(
           child: Center(
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 // Prefix icon
                 if (prefixIcon != null) ...[
                   SizedBox(
                     width: SizeConstants.buttonLoaderWidgetMedium,
                     child: prefixIcon,
                   ),
                   const SizedBox(width: Spacing.sm),
                 ],
                 if (handleOverflow == true) ...[
                   Flexible(
                     child: BlocBuilder<LanguageCubit, Locale>(
    builder: (context, locale) {
      final isEnglish = locale.languageCode == 'en';
                         return Text(
                           text,
                           textAlign: TextAlign.center,
                           softWrap: false,
                           overflow: TextOverflow.ellipsis,
                           strutStyle: AppUtils.tightStrut,

                           maxLines: 1,
                           style:
                               textStyle ??
                               TextStyle(
                                 fontFamily: AppFonts.calibrib,
                                 fontSize: isEnglish? FontSizes.medium :  FontSizes.medium -2,
                                 color:
                                     foregroundColor ??
                                     AppPalette.primaryAccent,
                                 fontWeight: fontWeight ?? FontWeight.bold,
                               ),
                         );
                       },
                     ),
                   ),
                 ] else
                   // Button text
                   Text(
                     text,
                     textAlign: TextAlign.center,
                     softWrap: false,
                     overflow: TextOverflow.ellipsis,
                     strutStyle: AppUtils.tightStrut,

                     maxLines: 1,
                     style:
                         textStyle ??
                         TextStyle(
                           fontFamily: AppFonts.calibrib,
                           fontSize: FontSizes.medium,
                           color: foregroundColor ?? AppPalette.primaryAccent,
                           fontWeight: fontWeight ?? FontWeight.bold,
                         ),
                   ),

                 // Suffix icon
                 if (suffixIcon != null) ...[
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
}
