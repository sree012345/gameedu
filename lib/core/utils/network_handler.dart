/*
 * -----------------------------------------------------------------------------
 * File        : lib\core\utils\network_handler.dart
 * Description : NetworkHandler - handles core functionality
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-04-28
 * Last Updated: 2026-04-28
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : NetworkHandler
 * Purpose     : Provides utilities for handling network operations, including internet connectivity checks 
 *               and safe execution of network requests with error handling.
 * -----------------------------------------------------------------------------
 */

import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';
import 'package:game_edu/core/widgets/buttons/medium_outline_button.dart';
import 'package:game_edu/core/widgets/popup/es_dialog_box.dart';
import 'package:game_edu/main.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';


enum NetworkStatus { success, noInternet, error }

class NetworkResult<T> {
  final T? data;
  final NetworkStatus status;
  final String? message;
  final Object? error;

  const NetworkResult._({
    this.data,
    required this.status,
    this.message,
    this.error,
  });

  factory NetworkResult.success(T data) {
    return NetworkResult._(data: data, status: NetworkStatus.success);
  }

  factory NetworkResult.noInternet() {
    return NetworkResult._(
      status: NetworkStatus.noInternet,
      message: 'dashboard.network.offline'.tr(),
    );
  }

  factory NetworkResult.error(Object error, {String? message}) {
    return NetworkResult._(
      status: NetworkStatus.error,
      error: error,
      message: message ?? error.toString(),
    );
  }

  bool get isSuccess => status == NetworkStatus.success;
  bool get isNoInternet => status == NetworkStatus.noInternet;
  bool get isError => status == NetworkStatus.error;

  void operator [](String other) {}
}

class NetworkHandler {
  NetworkHandler._();

  /// Internet check (best-effort, not truth)
  static Future<bool> hasInternet() async {
    try {
      return await InternetConnection().hasInternetAccess;
    } catch (_) {
      return false;
    }
  }

  /// Safe execution
  static Future<NetworkResult<T>> executeSafe<T>({
    required Future<T> Function() action,
  }) async {
    final isOnline = await hasInternet();

    if (!isOnline) {
      return NetworkResult.noInternet();
    }

    try {
      final result = await action();
      return NetworkResult.success(result);
    } on SocketException catch (e) {
      return NetworkResult.error(
        e,
        message: 'dashboard.network.no_connection'.tr(),
      );
    } on HttpException catch (e) {
      return NetworkResult.error(
        e,
        message: 'dashboard.network.server_not_responding'.tr(),
      );
    } on FormatException catch (e) {
      return NetworkResult.error(
        e,
        message: 'dashboard.network.invalid_response'.tr(),
      );
    } on TimeoutException catch (e) {
      return NetworkResult.error(
        e,
        message: 'dashboard.network.request_timeout'.tr(),
      );
    } catch (e) {
      return NetworkResult.error(
        e,
        message: 'dashboard.network.unexpected_error'.tr(),
      );
    }
  }
}

class NetworkExecutor {
  NetworkExecutor._();
  static bool _isDialogOpen = false;
  static Future<NetworkResult<T>> executeWithRetry<T>({
    required Future<T> Function() action,
  }) async {
    NetworkResult<T> result = await NetworkHandler.executeSafe(action: action);

    while (result.isNoInternet) {
      if (_isDialogOpen) {
        return result; // 🚫 prevent multiple dialogs
      }

      if (rootNavKey.currentContext != null) {
        _isDialogOpen = true;

        final shouldRetry = await _showNoInternetDialog(
          rootNavKey.currentContext!,
        );

        _isDialogOpen = false;

        if (!shouldRetry) {
          return result;
        }

        result = await NetworkHandler.executeSafe(action: action);
      }
    }

    return result;
  }

  // NEW — for long-running actions (uploads) where the connection can
  // drop mid-flight, not just before the action starts.
  static Future<NetworkResult<T>> executeLongRunningWithRetry<T>({
    required Future<T> Function() action,
  }) async {
    bool finished = false;
    T? successData;
    Object? failureError;
    StreamSubscription<InternetStatus>? sub;

    final actionFuture = action().then((data) {
      finished = true;
      successData = data;
    }).catchError((e) {
      finished = true;
      failureError = e;
    });

    Future<void> maybeShowDialog() async {
      if (finished || _isDialogOpen) return;
      if (rootNavKey.currentContext == null) return;
      _isDialogOpen = true;
      final shouldRetry = await NetworkExecutor._showNoInternetDialog(
        rootNavKey.currentContext!,
      );
      _isDialogOpen = false;
      if (finished) return;
      if (shouldRetry) {
        // ✅ NEW — actively re-check instead of waiting for a stream event
        final online = await NetworkHandler.hasInternet();
        if (!online && !finished) {
          await maybeShowDialog(); // still offline — show again immediately
        }
        // if online, the underlying action resolves naturally when it can;
        // if it disconnects again later, onStatusChange below will catch it
      }
    }

    sub = InternetConnection().onStatusChange.listen((status) async {
      if (status == InternetStatus.disconnected) {
        await maybeShowDialog();
      }
    });

    await actionFuture;
    await sub.cancel();

    if (failureError != null) {
      return NetworkResult.error(failureError!);
    }
    return NetworkResult.success(successData as T);
  }


  static Future<bool> _showNoInternetDialog(BuildContext context) async {
    final completer = Completer<bool>();

    await EsDialogBox.show(
      width: 500,
      context: context,
      barrierDismissible: false,
      child: _NoInternetDialog(
        onRetry: () => completer.complete(true),
        onClose: () => completer.complete(false),
      ),
    );

    return completer.future;
  }
}

class _NoInternetDialog extends StatefulWidget {
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _NoInternetDialog({required this.onRetry, required this.onClose});

  @override
  State<_NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<_NoInternetDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 400,
          // child: OfflineContentDetails(
          //   isCommmonPopup: true,
          //   logoSize: 80,
          //   title: SplashSubheading.medium,
          //   label: SplashLabel.medium,
          //   subLabel: SplashSubLabel.medium,
          // ),
        ),

        Row(
          children: [
            Expanded(
              child: MediumButton(
                text: 'dashboard.network.retry'.tr(),
                isLoading: isLoading,
                onPressed: () async {
                  setState(() => isLoading = true);

                  widget.onRetry();

                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MediumOutlineButton(
                text: 'dashboard.network.close'.tr(),
                onPressed: () {
                  widget.onClose();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            [
              'splash.offline_splash.bottom_label.label_1'.tr(),
              'splash.offline_splash.bottom_label.label_2'.tr(),
            ].join(' • '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: SplashLabel.medium,
              color: AppPalette.textSecondaryColor,
              fontWeight: FontWeights.light100,
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool> checkInternet() async {
  try {
    return await NetworkHandler.hasInternet();
  } catch (_) {
    return false;
  }
}
