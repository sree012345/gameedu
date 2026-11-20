import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/routes/router_path.dart';

import '../../bloc/dashboard_bloc.dart';

/// Asks "Are you sure you want to logout?". Logs out only on confirm.
Future<void> confirmLogout(BuildContext context) async {
  final bloc = context.read<DashboardBloc>();

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
                color: AppPalette.errorText.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 30,
                color: AppPalette.errorText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Logout?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppPalette.authTextSecondaryColor,
              ),
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
                      backgroundColor: AppPalette.errorText,
                      foregroundColor: AppPalette.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

 if (confirmed == true) {
  bloc.add(const DashboardLogoutConfirmed());

  if (!context.mounted) return;

  Navigator.of(context).pushNamedAndRemoveUntil(
    RouterPath.loginStep,
    (route) => false,
  );
}
}
