/*
 * -----------------------------------------------------------------------------
 * File        : lib/widgets/base/rr_textfield.dart
 * Description : Reusable customizable TextFormField widget with password toggle.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-01-12
 * Last Updated: 2025-01-12
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Widget      : BaseTextfield
 * Purpose     :
 * Provides a flexible text input field with validation, styling, and optional
 * password visibility toggle support.
 *
 * Responsibilities:
 * - Display a stylized TextField with optional padding and hint text.
 * - Support for password fields with show/hide toggle functionality.
 * - Accept external controller, validation, keyboard type, and submission handling.
 *
 * UI Composition:
 * - InputDecoration: Custom hint styling, error styling, borders, and padding.
 * - SuffixIcon: Optional password visibility toggle icon.
 *
 * Usage:
 * Use this widget inside forms (e.g., login, signup) for consistent and
 * reusable text input with optional secure entry support.
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_edu/common/theme/app_palette.dart';

class BaseTextfield extends StatelessWidget {
  // Controllers & focus
  final TextEditingController? controller;
  final FocusNode? focusNode;

  // Text
  final String? hintText;
  final String? errorText;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  // Limits
  final int? maxLength;
  final int? maxLines;
  final int? minLines;

  // State
  final bool? enabled;
  final bool? readOnly;

  // Keyboard
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  // Password
  final bool? obscureText;

  // Prefix
  final Widget? prefixIcon;
  final bool? isSuffixIcon;
  final IconData? suffixIcon;
  final double? suffixIconSize;
  final EdgeInsets? suffixIconPadding;
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;

  final VoidCallback? onSuffixIconTapped;

  // Styling
  final Color? textColor;
  final Color? hintColor;
  final Color? errorTextColor;
  final Color? suffixIconColor;

  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? focusedErrorBorderColor;
  final double borderWidth;
  final Color? cursorColor;
  final bool filled;
  final Color? fillColor;
  final double fontSize;
  final double? errorFontSize;
  final int? errorMaxLines;

  // Radius control
  final double borderRadius;
  final bool isSquare;

  // Other
  final Function(PointerDownEvent)? onTapOutside;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final bool showErrorBorder;
  final EdgeInsets? contentPadding;
  final bool showOuterBorder;

  const BaseTextfield({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.enabled,
    this.readOnly,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText,
    this.prefixIcon,
    this.isSuffixIcon,
    this.suffixIcon,
    this.suffixIconSize,
    this.suffixIconPadding,
    this.suffixIconConstraints,
    this.onSuffixIconTapped,
    this.textColor,
    this.hintColor,
    this.errorTextColor,
    this.suffixIconColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.focusedErrorBorderColor,
    this.borderWidth = 1.5,
    this.cursorColor,
    this.filled = false,
    this.fillColor,
    this.fontSize = 16,
    this.errorFontSize,
    this.errorMaxLines,
    this.borderRadius = 28,
    this.isSquare = false,
    this.onTapOutside,
    this.showErrorBorder = false,
    this.prefixIconConstraints,
    this.contentPadding,
    this.autocorrect = false,
    this.enableSuggestions = false,
    // The inner OutlineInputBorder already draws the border, so the extra
    // outer border is off by default to avoid a double border.
    this.showOuterBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveRadius = isSquare ? 0 : borderRadius;

    final Color effectiveBorderColor =
        borderColor ?? AppPalette.inputBorderColor;

    final Color effectiveFocusedBorderColor =
        focusedBorderColor ?? AppPalette.inputFocusedBorderColor;

    final Color effectiveErrorBorderColor =
        errorBorderColor ?? AppPalette.errorBorderColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(effectiveRadius),
          // White input surface
          color: fillColor ?? AppPalette.authCardSurfaceColor,
          border: showOuterBorder
              ? Border.all(color: effectiveBorderColor, width: borderWidth)
              : null,
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onTapOutside: onTapOutside,
          onChanged: onChanged,
          onSubmitted: onFieldSubmitted,
          maxLines: obscureText == true ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly ?? false,
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.none,
          autocorrect: autocorrect ?? false,
          enableSuggestions: enableSuggestions ?? false,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          obscureText: obscureText ?? false,
          cursorColor: cursorColor ?? AppPalette.primaryBlue,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor ?? AppPalette.authTextPrimaryColor,
          ),
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            hintText: hintText,
            errorText: errorText,
            errorMaxLines: errorMaxLines,
            errorStyle: TextStyle(
              fontSize: errorFontSize ?? 12,
              color: errorTextColor ?? AppPalette.errorText,
            ),
            hintStyle: TextStyle(
              fontSize: fontSize,
              color: hintColor ?? AppPalette.hintTextColor,
            ),

            contentPadding:
                contentPadding ??
                EdgeInsets.fromLTRB(
                  16,
                  16,
                  (isSuffixIcon ?? false) ? 40 : 16,
                  16,
                ),

            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            suffixIconConstraints: suffixIconConstraints,
            suffixIcon: isSuffixIcon ?? false
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onSuffixIconTapped,
                      child: Padding(
                        padding: suffixIconPadding ?? EdgeInsets.zero,
                        child: Icon(
                          suffixIcon,
                          size: suffixIconSize,
                          color:
                              suffixIconColor ??
                              textColor ??
                              AppPalette.inputIconColor,
                        ),
                      ),
                    ),
                  )
                : null,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
              borderSide: BorderSide(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
              borderSide: BorderSide(
                color: effectiveFocusedBorderColor,
                width: borderWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
              borderSide: BorderSide(
                color: effectiveErrorBorderColor,
                width: borderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
              borderSide: BorderSide(
                color: focusedErrorBorderColor ?? effectiveErrorBorderColor,
                width: borderWidth,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
              borderSide: BorderSide(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}