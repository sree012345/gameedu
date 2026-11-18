/*
 * ----------------------------------------------------------------------------------------------------------------
 * File         : lib/core/push_notification/notification_credentials.dart
 * Description  : Responsible for maintaing the Firebase app credentials for push notification              
 * Author       : Revolution Games Private Limited
 * Created On   : 2025-10-04
 * Last Updated : 2025-10-04
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class        : NotificationCredentials
 * Purpose      : To maintain the Firebase app credential 
 * -----------------------------------------------------------------------------
 */

import 'package:firebase_core/firebase_core.dart';

class NotificationCredentials {
  static const FirebaseOptions _firebaseAuthOptions = FirebaseOptions(
    apiKey: "AIzaSyCo2eZ0u5_MdI3M_5zRSH4t0xrKJHu0u9g",
    authDomain: "revogram-test.firebaseapp.com",
    projectId: "revogram-test",
    storageBucket: "revogram-test.firebasestorage.app",
    messagingSenderId: "468455985319",
    appId: "1:468455985319:web:32677aaeb9ff7e19a30b82",
    measurementId: "G-JZN1NW9RC2",
  );
  static FirebaseOptions get firebaseCredential => _firebaseAuthOptions;
  static const String fcmApiKey =
      'BLljJogKtqLjdFJHeMwkC2YXIO-z4LxwoRUp3LgFyYHDed5zaDBstee7voB-qJKakiJERJgBSCoUiJIgftBESNM';
}
