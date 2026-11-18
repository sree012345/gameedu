import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

/// Temporary screen shown after successful OTP verification.
/// Replace the call in `AuthNavigator.toHome` with your real home screen.
class AuthNextScreenPlaceholder extends StatelessWidget {
  const AuthNextScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppPalette.authCardSurfaceColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 72,
              color: AppPalette.successColor,
            ),
            SizedBox(height: 16),
            Text(
              'Verified! Next screen goes here.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
