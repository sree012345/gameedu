/*
 * -----------------------------------------------------------------------------
 * File         : lib/core/push_notification/notification_messaging_service.dart
 * Description  : Responsible for performing Notification messaging dependencies integration from firebase channels on app state 
 * Author       : Revolution Games Private Limited
 * Created On   : 2025-10-04
 * Last Updated : 2025-10-04
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class        : NotificationMessagingService
 * Purpose      : To Listen the push notification messaging in with help of firebase channel on app state  
 * -----------------------------------------------------------------------------
 */

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationMessagingService {
  static initializeOnForegroundListenPns() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  }
}
