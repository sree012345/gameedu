import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

/// Red server / Firebase error shown under the Login / Register / Verify
/// button. Takes no space when there is no error.
class AuthServerError extends StatelessWidget {
  const AuthServerError({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppPalette.errorText,
        ),
      ),
    );
  }
}
