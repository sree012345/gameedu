import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

/// "Do you want to register for <event name>?"  ->  true when confirmed.
Future<bool> confirmEventRegistration(
  BuildContext context, {
  required String eventTitle,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppPalette.authCardSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.primaryBlue.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 30,
                color: AppPalette.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Register for this event?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: AppPalette.authTextSecondaryColor,
                ),
                children: [
                  const TextSpan(text: 'Do you want to register for '),
                  TextSpan(
                    text: eventTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppPalette.authTextPrimaryColor,
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.authTextPrimaryColor,
                      side: const BorderSide(
                        color: AppPalette.inputBorderColor,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primaryBlue,
                      foregroundColor: AppPalette.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  return confirmed == true;
}
