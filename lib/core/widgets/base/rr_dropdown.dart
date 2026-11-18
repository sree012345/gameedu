/*
 * ----------------------------------------------------------------------------- 
 * File        : lib\widgets\base\rr_dropdown.dart
 * Description : Custom dropdown widget with extensive styling and customization options.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-01
 * Last Updated: 2025-12-01
 * ----------------------------------------------------------------------------- 
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * ----------------------------------------------------------------------------- 
 *
 * Class       : RrDropdown
 * Purpose     : Provides a customizable dropdown input widget with styling and behavior options.
 *
 * Parameters:
 * - items             : List of string options to display in the dropdown.
 * - selectedValue     : Currently selected value; must be one of the items or null.
 * - onChanged         : Callback when dropdown selection changes.
 * - hintText          : Optional placeholder text shown when no item is selected.
 * - height            : Height of the dropdown container; defaults to 60.0.
 * - borderRadius      : Radius for the dropdown corners; defaults to large radius constant.
 * - padding           : Padding inside the container around the dropdown widget.
 * - dropdownColor     : Background color of the dropdown menu.
 * - textColor         : Text color of the dropdown hint and selected value.
 * - iconEnabledColor  : Color of the dropdown arrow icon when enabled.
 * - iconDisabledColor : Color of the dropdown arrow icon when disabled.
 * - borderColor       : Border color of the dropdown field when enabled.
 * - focusedBorderColor: Border color of the dropdown field when focused.
 * - inputDecoration   : Optional custom InputDecoration to override default styling.
 * - dropdownStyleData : Custom dropdown menu styling options.
 * - menuItemStyleData : Custom styling for the dropdown menu items.
 * - iconStyleData     : Custom styling for the dropdown icon.
 * - customIcon        : Optional widget to replace the default dropdown arrow icon.
 * - enabled           : Whether the dropdown is enabled or disabled.
 * - menuTextColor     : Optional color for the dropdown menu item text.
 * ----------------------------------------------------------------------------- 
 */


import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/constants/ui/padding_constants.dart';
import 'package:game_edu/common/constants/ui/radius_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';

class RrDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final String? hintText;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? dropdownColor;
  final Color? textColor;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final InputDecoration? inputDecoration;
  final DropdownStyleData? dropdownStyleData;
  final MenuItemStyleData? menuItemStyleData;
  final IconStyleData? iconStyleData;
  final Widget? customIcon;
  final bool enabled;
  final Color? menuTextColor;
  final double? fontSize;
  final double? borderWidth;
  final double? iconSize;
  final double? dropdownMenuHeight;
  final double? verticalContentPadding;
  final ImageProvider? backgroundImage;

  const RrDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.hintText,
    this.dropdownMenuHeight,
    this.height = 60.0,
    this.borderRadius = RadiusConstants.large,
    this.padding = const EdgeInsets.all(PaddingConstants.small),
    this.dropdownColor = AppPalette.cardSurfaceColor,
    this.textColor = AppPalette.textPrimaryColor,
    this.iconEnabledColor = AppPalette.textPrimaryColor,
    this.iconDisabledColor = AppPalette.elevatedSurfaceColor,
    this.borderColor = AppPalette.transparentColor,
    this.focusedBorderColor = AppPalette.transparentColor,
    this.menuTextColor,
    this.inputDecoration,
    this.dropdownStyleData,
    this.menuItemStyleData,
    this.iconStyleData,
    this.customIcon,
    this.enabled = true,
    this.fontSize,
    this.borderWidth,
    this.iconSize,
    this.verticalContentPadding = 14.0,
    this.backgroundImage,
  });

  @override
  State<RrDropdown> createState() => _RrDropdownState();
}

class _RrDropdownState extends State<RrDropdown> {
  late final ValueNotifier<String?> _selectedValueNotifier;

  String? _validValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!widget.items.contains(value)) {
      return null;
    }

    return value;
  }

  @override
  void initState() {
    super.initState();

    _selectedValueNotifier = ValueNotifier<String?>(
      _validValue(widget.selectedValue),
    );
  }

  @override
  void didUpdateWidget(covariant RrDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedValue != widget.selectedValue ||
        oldWidget.items != widget.items) {
      final newValue = _validValue(widget.selectedValue);

      if (_selectedValueNotifier.value != newValue) {
        _selectedValueNotifier.value = newValue;
      }
    }
  }

  @override
  void dispose() {
    _selectedValueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
        color: AppPalette.cardSurfaceColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),

          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'Region',
              style: TextStyle(
                color: AppPalette.textSecondaryColor,
                fontSize: TextFieldLabel.large,
                fontWeight: FontWeights.bold600,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(1),
            height: widget.height,
            width: double.infinity,
            child: DropdownButtonFormField2<String>(
              // Updated for dropdown_button2 3.x
              valueListenable: _selectedValueNotifier,

              isExpanded: true,
              isDense: false,

              onChanged: widget.enabled
                  ? (String? value) {
                      _selectedValueNotifier.value = value;

                      widget.onChanged?.call(value);
                    }
                  : null,

              hint: Text(
                widget.hintText ?? '',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
                style: TextStyle(
                  color: AppPalette.textPrimaryColor,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.normal,
                ),
              ),

              // Updated DropdownMenuItem to DropdownItem
              items: widget.items
                  .map(
                    (item) => DropdownItem<String>(
                      value: item,
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                        style: TextStyle(
                          color: widget.menuTextColor,
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                  .toList(),

              // Input decoration - original design
              decoration:
                  widget.inputDecoration ??
                  InputDecoration(
                    isCollapsed: true,
                    filled: true,
                    fillColor: AppPalette.cardSurfaceColor,

                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(
                        color: AppPalette.cardSurfaceColor,
                      ),
                    ),

                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(
                        color: AppPalette.cardSurfaceColor,
                      ),
                    ),

                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(
                        color: AppPalette.cardSurfaceColor,
                      ),
                    ),

                    isDense: false,
                    contentPadding: EdgeInsets.symmetric(
                      vertical:
                          widget.verticalContentPadding ?? 14.0,
                    ),
                  ),

              // Dropdown style - original design
              dropdownStyleData:
                  widget.dropdownStyleData ??
                  DropdownStyleData(
                    decoration: BoxDecoration(
                      color: widget.dropdownColor,
                    ),
                    maxHeight: widget.dropdownMenuHeight,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),

              // Icon style - original design
              iconStyleData:
                  widget.iconStyleData ??
                  IconStyleData(
                    icon:
                        widget.customIcon ??
                        Icon(
                          Icons.arrow_drop_down,
                          size: widget.iconSize,
                        ),
                    iconEnabledColor: widget.iconEnabledColor,
                    iconDisabledColor: widget.iconDisabledColor,
                  ),

              menuItemStyleData:
                  widget.menuItemStyleData ??
                  const MenuItemStyleData(),
            ),
          ),
        ],
      ),
    );
  }
}
