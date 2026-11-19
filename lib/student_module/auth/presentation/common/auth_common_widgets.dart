import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

/// Shows a snackbar only on the screen that is currently visible.
/// (Login / Register stay in the stack behind the OTP screen, so without
/// this check the same message could be shown twice.)
void showAuthMessage(BuildContext context, String message) {
  if (ModalRoute.of(context)?.isCurrent != true) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.authTextPrimaryColor,
      ),
    );
}

/// "Welcome Back" style heading with a blue highlighted last word.
class AuthTitle extends StatelessWidget {
  const AuthTitle({
    super.key,
    required this.title,
    required this.highlight,
    this.subtitle,
  });

  final String title;
  final String highlight;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
            children: [
              TextSpan(
                text: '$title ',
                style: const TextStyle(color: AppPalette.authTextPrimaryColor),
              ),
              TextSpan(
                text: highlight,
                style: const TextStyle(color: AppPalette.primaryBlue),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppPalette.authTextSecondaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Small red message shown under a field.
class AuthErrorText extends StatelessWidget {
  const AuthErrorText(this.message, {super.key, this.center = false});

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

/// "or continue with" divider.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppPalette.authDividerColor, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppPalette.authTextSecondaryColor,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppPalette.authDividerColor, thickness: 1),
        ),
      ],
    );
  }
}

/// White pill button with icon + label (Google / Mobile).
class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: AppPalette.secondaryButtonBgColor,
        clipBehavior: Clip.antiAlias,
        shape: const StadiumBorder(
          side: BorderSide(color: AppPalette.inputBorderColor, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppPalette.primaryBlue, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.secondaryButtonTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Don't have an account? / Register" block.
class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          prompt,
          style: const TextStyle(
            fontSize: 15,
            color: AppPalette.authTextSecondaryColor,
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppPalette.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthTermsText extends StatelessWidget {
  const AuthTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'By continuing you agree to our Terms of Use & Privacy Policy',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: AppPalette.authTextSecondaryColor),
    );
  }
}

/// Checkbox row for the Register screen.
class AuthTermsCheckbox extends StatelessWidget {
  const AuthTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: value,
                    onChanged: (v) => onChanged(v ?? false),
                    activeColor: AppPalette.primaryBlue,
                    checkColor: AppPalette.white,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: BorderSide(
                      color: errorText != null
                          ? AppPalette.errorBorderColor
                          : AppPalette.inputBorderColor,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'I agree to the Terms of Use and Privacy Policy',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppPalette.authTextSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) AuthErrorText(errorText!),
      ],
    );
  }
}

/// Tinted info box (shield icon + two lines) on the OTP screen.
class AuthInfoCard extends StatelessWidget {
  const AuthInfoCard({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.infoSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.inputBorderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppPalette.primaryBlue,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.authTextPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppPalette.authTextSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
