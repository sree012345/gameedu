import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:flutter/material.dart';

class NetworkUtils {
  static Future<bool> hasInternet() async {
    try {
      return await InternetConnection().hasInternetAccess;
    } catch (_) {
      return false;
    }
  }
}

class NetworkPopup {
  static Future<void> showNoInternetDialog(
    BuildContext context, {
    Future<void> Function()? onRetry, 
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("No Internet"),
          content: const Text("Please check your connection and try again."),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (onRetry != null) {
                  await onRetry();
                }
              },
              child: Text(onRetry != null ? "OK" : "Retry"),
            ),
          ],
        );
      },
    );
  }
}

class NetworkGuard {
  /// ✔ returns true → internet available
  /// ✔ returns false → popup shown
  static Future<bool> check(
    BuildContext context, {
    Future<void> Function()? onRetry, // 🔥 optional retry
  }) async {
    final isOnline = await NetworkUtils.hasInternet();

    if (!isOnline) {
      await NetworkPopup.showNoInternetDialog(context, onRetry: onRetry);
      return false;
    }

    return true;
  }

  /// 🔥 Clean execution wrapper
  static Future<void> run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final isOnline = await NetworkUtils.hasInternet();

    if (!isOnline) {
      await NetworkPopup.showNoInternetDialog(
        context,
        onRetry: action, 
      );
      return;
    }

    await action();
  }
}
