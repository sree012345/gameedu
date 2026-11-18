/*
 * -----------------------------------------------------------------------------
 * File        : lib\widgets\dropdown\medium_drop_down.dart
 * Description : Defines the responsive roles listing page with device-specific views.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-01
 * Last Updated: 2025-12-01
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : MediumDropDown
 * Purpose     : Provides a medium-sized styled dropdown with customized colors and behavior.
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/foundation.dart';
import 'package:game_edu/common/constants/ui/radius_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/rr_dropdown.dart';

class MediumDropDown extends RrDropdown {
  // ignore: use_super_parameters
  MediumDropDown({
    super.key,

    /// Required dropdown items and callback
    required super.items,
    required super.onChanged,

    /// Optional selected value to control the dropdown
    String? selectedValue,

    /// Optional initial value used on first build
    String? initialValue,

    double? height,
    double? fontSize,
    super.dropdownMenuHeight,

    /// Optional hint text
    super.hintText,
  }) : super(
         selectedValue: (initialValue != null && items.contains(initialValue))
             ? initialValue
             : selectedValue,

         /// Height of the dropdown
         height:  kIsWeb ? 45 : height ?? 50,

         /// Radius style for medium button
         borderRadius: RadiusConstants.inputBorderRadius,

         /// Dropdown style colors
         dropdownColor: AppPalette.cardSurfaceColor,
         borderColor: AppPalette.cardSurfaceColor,
         focusedBorderColor: AppPalette.cardSurfaceColor,
         iconEnabledColor: AppPalette.disabledColor,
         iconDisabledColor: AppPalette.elevatedSurfaceColor,
    
         /// Text colors
         textColor: AppPalette.textPrimaryColor,
         menuTextColor: AppPalette.textPrimaryColor,
         fontSize: fontSize,
         verticalContentPadding: 10.0,
        //  backgroundImage: AssetImage(ImageAssets.rrTextboxMedium),
       );
}
