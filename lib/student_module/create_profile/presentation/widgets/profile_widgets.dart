import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/base_textfield.dart';

/// Small red message under a field.
class ProfileErrorText extends StatelessWidget {
  const ProfileErrorText(this.message, {super.key, this.center = false});

  final String message;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6, left: center ? 0 : 16),
      child: Text(
        message,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(fontSize: 12, color: AppPalette.errorText),
      ),
    );
  }
}

class ProfileLabel extends StatelessWidget {
  const ProfileLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppPalette.authTextPrimaryColor,
      ),
    );
  }
}

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: AppPalette.authTextPrimaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppPalette.authTextSecondaryColor,
          ),
        ),
      ],
    );
  }
}

/// Label + [BaseTextfield] + error text (drawn outside the field so the
/// pill keeps the same height when an error appears).
class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
  });

  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileLabel(label),
        const SizedBox(height: 8),
        BaseTextfield(
          controller: controller,
          hintText: hint,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          borderColor: hasError ? AppPalette.errorBorderColor : null,
          focusedBorderColor: hasError ? AppPalette.errorBorderColor : null,
          prefixIcon: Icon(prefixIcon, color: AppPalette.inputIconColor, size: 22),
        ),
        if (hasError) ProfileErrorText(errorText!),
      ],
    );
  }
}

/// Pill used for Gender and Year of Study.
class ProfileChoicePill extends StatelessWidget {
  const ProfileChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppPalette.primaryBlue : AppPalette.authCardSurfaceColor,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppPalette.primaryBlue : AppPalette.inputBorderColor,
          width: 1.5,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected
                    ? AppPalette.white
                    : AppPalette.authTextSecondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
