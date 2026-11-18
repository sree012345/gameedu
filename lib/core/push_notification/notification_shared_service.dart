/*
 * -----------------------------------------------------------------------------
 * File         : lib/core/push_notification/notification_shared_service.dart
 * Description  : Responsible for store and to maintain the Notification device token integration on app level
 * Author       : Revolution Games Private Limited
 * Created On   : 2025-10-04
 * Last Updated : 2025-10-04
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class        : NotificationSharedService
 * Purpose      : To Maintain the push notification device token  with help of firebase Authentication  
 * -----------------------------------------------------------------------------
 */
import 'package:game_edu/core/push_notification/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTokenModel {
  final String? token;
  final String? deviceType;

  const NotificationTokenModel({required this.token, required this.deviceType});
}

class NotificationSharedService {
  static const String _storageKey = "pns_device_token";
  static Future<NotificationTokenModel?> get getPnsToken => getPnsDeviceToken();

  static Future<void> storePnsDeviceToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_storageKey, token);
  }

  static Future<NotificationTokenModel?> getPnsDeviceToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return NotificationTokenModel(
      token: prefs.getString(_storageKey),
      deviceType: NotificationService.getPlatformMapper(),
    );
  }
}
