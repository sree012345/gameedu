import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/base_textfield.dart';

import '../../../create_profile/presentation/widgets/profile_widgets.dart'
    show ProfileErrorText, ProfileLabel;

/// Label + [BaseTextfield] + error text. Can be read-only (greyed) and can
/// show a [trailing] widget inside the field (e.g. "Add Number").
class EditTextField extends StatelessWidget {
  const EditTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.readOnly = false,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.trailing,
    this.keyboardType = TextInputType.text,
    this.helperText,
  });

  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;

  /// Small grey hint under the field (hidden while an error is shown).
  final String? helperText;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileLabel(label),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            BaseTextfield(
              controller: controller,
              hintText: hint,
              onChanged: onChanged,
              readOnly: readOnly,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              fillColor: readOnly
                  ? AppPalette.inputBorderColor.withValues(alpha: 0.35)
                  : null,
              textColor: readOnly ? AppPalette.authTextSecondaryColor : null,
              borderColor: hasError ? AppPalette.errorBorderColor : null,
              focusedBorderColor: hasError ? AppPalette.errorBorderColor : null,
              prefixIcon: Icon(
                prefixIcon,
                color: AppPalette.inputIconColor,
                size: 22,
              ),
            ),
            if (trailing != null)
              Positioned(right: 8, child: trailing!),
          ],
        ),
        if (hasError)
          ProfileErrorText(errorText!)
        else if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Text(
              helperText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.authTextSecondaryColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// Dropdown look (chevron) built on [BaseTextfield]; tapping opens
/// [showProfileOptionSheet].
class ProfileSelectField extends StatefulWidget {
  const ProfileSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.valueLabel,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String hint;
  final IconData prefixIcon;

  /// Text of the selected option ('' when nothing is selected).
  final String valueLabel;
  final VoidCallback onTap;
  final String? errorText;

  @override
  State<ProfileSelectField> createState() => _ProfileSelectFieldState();
}

class _ProfileSelectFieldState extends State<ProfileSelectField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.valueLabel,
  );

  @override
  void didUpdateWidget(covariant ProfileSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valueLabel != _controller.text) {
      _controller.text = widget.valueLabel;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileLabel(widget.label),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AbsorbPointer(
            child: BaseTextfield(
              controller: _controller,
              hintText: widget.hint,
              readOnly: true,
              borderColor: hasError ? AppPalette.errorBorderColor : null,
              focusedBorderColor: hasError ? AppPalette.errorBorderColor : null,
              prefixIcon: Icon(
                widget.prefixIcon,
                color: AppPalette.inputIconColor,
                size: 22,
              ),
              isSuffixIcon: true,
              suffixIcon: Icons.keyboard_arrow_down_rounded,
              suffixIconSize: 26,
              suffixIconPadding: const EdgeInsets.only(right: 4),
              suffixIconColor: AppPalette.authTextSecondaryColor,
            ),
          ),
        ),
        if (hasError) ProfileErrorText(widget.errorText!),
      ],
    );
  }
}

/// Bottom sheet with a list of options. Returns the chosen value.
Future<T?> showProfileOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<(String, T)> options,
  T? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppPalette.transparentColor,
    builder: (ctx) => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppPalette.inputBorderColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            for (final (label, value) in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppPalette.authTextPrimaryColor,
                  ),
                ),
                trailing: value == selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppPalette.successColor,
                      )
                    : null,
                onTap: () => Navigator.of(ctx).pop(value),
              ),
          ],
        ),
      ),
    ),
  );
}
