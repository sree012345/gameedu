/*
 * ----------------------------------------------------------------------------- 
 * File        : lib\widgets\base\rr_dropdown.dart
 * Description : Custom dropdown widget with extensive styling and customization options.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-01-12
 * Last Updated: 2025-01-12
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
import 'package:game_edu/common/constants/ui/radius_constants.dart';
import 'package:game_edu/common/constants/ui/size_constants.dart';
import 'package:game_edu/common/constants/ui/spacing_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';

class BaseDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? hintText;
  final double fontSize;
  final double borderRadius;
  final double borderWidth;
  final double verticalContentPadding;
  final double? height;
  final Color? overlayBorderColor;
  final Color? overlayColor;
  final Color? fieldColor;
  final double? overlayWidth;
  final double? overlayHeight;
  final Color? borderlayerColor;
  final double? iconSize;

  const BaseDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.hintText,
    this.fontSize = 24,
    this.borderRadius = RadiusConstants.dropdownRadius,
    this.overlayColor,
    this.borderWidth = SizeConstants.dropDownBorderWidth,
    this.height = 44,
    this.verticalContentPadding = 10,
    this.overlayBorderColor,
    this.fieldColor,
    this.overlayWidth,
    this.iconSize,
    this.overlayHeight,
    this.borderlayerColor,
  });

  @override
  State<BaseDropdown> createState() => _BaseDropdownState();
}

class _BaseDropdownState extends State<BaseDropdown> {
  late final ValueNotifier<String?> _selectedValueNotifier;

  String? _getValidSelectedValue(String? value) {
    if (value == null || !widget.items.contains(value)) {
      return null;
    }
    return value;
  }

  @override
  void initState() {
    super.initState();

    _selectedValueNotifier = ValueNotifier<String?>(
      _getValidSelectedValue(widget.selectedValue),
    );
  }

  @override
  void didUpdateWidget(covariant BaseDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedValue != widget.selectedValue ||
        oldWidget.items != widget.items) {
      final newValue = _getValidSelectedValue(
        widget.selectedValue,
      );

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
    final double effectiveRadius = widget.borderRadius;

    final Color borderColor =
        widget.overlayBorderColor ??
        AppPalette.elevatedSurfaceColor;

    final double? dropDownWidth = widget.overlayWidth;

    final dropDownDecorationStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(effectiveRadius),
      borderSide: BorderSide(
        color: borderColor,
        width: widget.borderWidth,
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: ClipRRect(
        child: Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveRadius),
            color: const Color(0xFF1F1F23),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: widget.borderWidth,
            ),
          ),
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              scrollbars: false,
            ),
            child: ScrollbarTheme(
              data: const ScrollbarThemeData(
                thumbVisibility: WidgetStatePropertyAll(true),
                thumbColor: WidgetStatePropertyAll(
                  AppPalette.elevatedSurfaceColor,
                ),
                thickness: WidgetStatePropertyAll(6),
                radius: Radius.circular(8),
              ),
              child: DropdownButtonFormField2<String>(
                // Updated: value -> valueListenable
                valueListenable: _selectedValueNotifier,

                isExpanded: true,

                onChanged: (String? value) {
                  _selectedValueNotifier.value = value;
                  widget.onChanged(value);
                },

                // Updated: FormFieldButtonStyleData
                buttonStyleData: FormFieldButtonStyleData(
                  height: widget.height ?? 44,
                ),

                hint: Text(
                  widget.hintText ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                // Updated: DropdownMenuItem -> DropdownItem
                items: widget.items
                    .map(
                      (item) => DropdownItem<String>(
                        value: item,
                        height: widget.fontSize * 2.2,
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1.0,
                            fontSize: widget.fontSize,
                            color: AppPalette.textPrimaryColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),

                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                    top: widget.verticalContentPadding,
                    bottom: widget.verticalContentPadding,
                  ),
                  disabledBorder: dropDownDecorationStyle,
                  enabledBorder: dropDownDecorationStyle,
                  focusedBorder: dropDownDecorationStyle,
                  border: dropDownDecorationStyle,
                ),

                // Dropdown overlay styling
                dropdownStyleData: DropdownStyleData(
                  offset: const Offset(0, -2),
                  isOverButton: false,
                  maxHeight: widget.overlayHeight,
                  width: dropDownWidth,
                  scrollPadding: const EdgeInsets.only(
                    top: Spacing.xs,
                    bottom: Spacing.xs,
                    left: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111118),
                    borderRadius: BorderRadius.all(
                      Radius.circular(effectiveRadius),
                    ),
                    border: Border.all(
                      color: AppPalette.elevatedSurfaceColor,
                      width: widget.borderWidth,
                    ),
                  ),
                ),

                // Updated: item height belongs to DropdownItem
                menuItemStyleData: MenuItemStyleData(
                  overlayColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                ),

                iconStyleData: IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: widget.iconSize,
                  ),
                  iconEnabledColor: Colors.white,
                  iconDisabledColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
