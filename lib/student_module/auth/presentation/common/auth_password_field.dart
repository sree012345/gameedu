import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import '../../constants/auth_constants.dart';
import 'auth_common_widgets.dart';

/// Label + password pill (show/hide toggle) + error text.
/// Styled with [AppPalette] to match [AuthTextField].
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color color, [double width = 1.5]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppPalette.authTextPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          enableSuggestions: false,
          autocorrect: false,
          maxLength: AuthConstants.passwordMaxLength,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: const TextStyle(
            fontSize: 16,
            color: AppPalette.authTextPrimaryColor,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppPalette.hintTextColor),
            filled: true,
            fillColor: AppPalette.authCardSurfaceColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppPalette.inputIconColor,
              size: 22,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppPalette.authTextSecondaryColor,
                size: 22,
              ),
            ),
            border: _border(AppPalette.inputBorderColor),
            enabledBorder: _border(
              hasError
                  ? AppPalette.errorBorderColor
                  : AppPalette.inputBorderColor,
            ),
            focusedBorder: _border(
              hasError
                  ? AppPalette.errorBorderColor
                  : AppPalette.inputFocusedBorderColor,
              2,
            ),
          ),
        ),
        if (hasError) AuthErrorText(widget.errorText!),
      ],
    );
  }
}
