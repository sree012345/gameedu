import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/base_textfield.dart';
import 'auth_common_widgets.dart';

/// Label + [BaseTextfield] + error text, as used on all auth forms.
///
/// The error text is drawn outside the field (not via InputDecoration) so
/// the white pill stays the same height when an error appears.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.suffixIconColor,
  });

  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  /// Use with [onTap] for picker-style fields (e.g. College).
  final bool readOnly;
  final VoidCallback? onTap;

  final IconData? suffixIcon;
  final Color? suffixIconColor;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    final field = BaseTextfield(
      controller: controller,
      focusNode: focusNode,
      hintText: hint,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      readOnly: readOnly,
      borderColor: hasError ? AppPalette.errorBorderColor : null,
      focusedBorderColor: hasError ? AppPalette.errorBorderColor : null,
      prefixIcon: Icon(prefixIcon, color: AppPalette.inputIconColor, size: 22),
      isSuffixIcon: suffixIcon != null,
      suffixIcon: suffixIcon,
      suffixIconColor: suffixIconColor,
      suffixIconSize: 24,
      suffixIconPadding: const EdgeInsets.only(right: 4),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppPalette.authTextPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        if (onTap == null)
          field
        else
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AbsorbPointer(child: field),
          ),
        if (hasError) AuthErrorText(errorText!),
      ],
    );
  }
}
