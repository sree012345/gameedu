import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

/// Temporary screen for routes that are not built yet.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.infoSurfaceColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppPalette.primaryBlue,
        foregroundColor: AppPalette.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 56,
              color: AppPalette.primaryBlue.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            const Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
