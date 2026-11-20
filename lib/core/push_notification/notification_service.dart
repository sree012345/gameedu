
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:game_edu/core/config/server_config.dart';
import 'package:game_edu/core/push_notification/in_app_overlay_notification.dart';
import 'package:game_edu/core/push_notification/notification_credentials.dart';
import 'package:game_edu/core/push_notification/notification_navigation_handler.dart';
import 'package:game_edu/core/push_notification/notification_shared_service.dart';
import 'package:game_edu/core/push_notification/params/current_route_track.dart';
import 'package:game_edu/core/push_notification/params/notification_platform_key_params.dart';
import 'package:game_edu/core/routes/router.dart';
import 'package:game_edu/main.dart';

import '../routes/router_path.dart';

class NotificationService {
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<User?>? _authSubscription;

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static AuthorizationStatus? _lastAuthStatus;
  static String? _lastKnownToken;
  static String? _lastSyncedUid;

  static void _log(String message) {
    debugPrint('🔔 [NotificationService] $message');
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  static Future<void> init() async {
    await firebaseInitialize();

    await initializeToken();

    await initializeNotificationListeners();

    listenToTokenRefresh();

    listenToAuthForToken();
  }

  // ============================================================
  // FIREBASE INITIALIZATION
  // ============================================================

  static Future<void> firebaseInitialize() async {
    if (Firebase.apps.isNotEmpty) {
      _log('Firebase already initialized');
      return;
    }

    if (kIsWeb) {
      await Firebase.initializeApp(
        options: NotificationCredentials.firebaseCredential,
      );
    } else {
      await Firebase.initializeApp();
    }

    _log('Firebase initialized successfully');
  }

  // ============================================================
  // FIREBASE COLLECTION
  // ============================================================

  static CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection(
      ServerConfig.usersCollection,
    );
  }

  // ============================================================
  // LISTEN TO FCM TOKEN REFRESH
  // ============================================================

  static void listenToTokenRefresh() {
    _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {
        _log('FCM token refreshed');

        _lastKnownToken = null;
        _lastSyncedUid = null;

        await _persistToken(newToken);
      },
      onError: (e, st) {
        _log('onTokenRefresh ERROR => $e');
        _log('$st');
      },
    );
  }

  // ============================================================
  // LISTEN TO AUTH CHANGES
  // ============================================================

  static void listenToAuthForToken() {
    _authSubscription?.cancel();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        if (user != null) {
          _log(
            'Auth changed -> logged in (${user.uid})',
          );

          // A different user must always sync their token.
          if (_lastSyncedUid != user.uid) {
            _lastKnownToken = null;
            _lastAuthStatus = null;
          }

          await refreshTokenNow();
        } else {
          _log('Auth changed -> logged out');

          _lastKnownToken = null;
          _lastAuthStatus = null;
          _lastSyncedUid = null;
        }
      },
      onError: (error) {
        _log('Auth listener ERROR => $error');
      },
    );
  }

  // ============================================================
  // CLEAR TOKEN BEFORE LOGOUT
  // ============================================================

  static Future<void> clearTokenOnLogout() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _log('clearTokenOnLogout: no logged-in user');
      return;
    }

    try {
      await _usersCollection.doc(user.uid).update({
        'pushToken': FieldValue.delete(),
      });

      _log(
        'Cleared pushToken for ${user.uid} '
        'from ${ServerConfig.usersCollection}',
      );
    } catch (e, st) {
      _log('clearTokenOnLogout ERROR => $e');
      _log('$st');
    } finally {
      _lastAuthStatus = null;
      _lastKnownToken = null;
      _lastSyncedUid = null;
    }
  }

  // ============================================================
  // REFRESH TOKEN WHEN APP RESUMES
  // ============================================================

  static Future<void> refreshTokenNow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _log(
        'refreshTokenNow: no user logged in, skipping',
      );
      return;
    }

    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      final status = settings.authorizationStatus;

      if (status == _lastAuthStatus &&
          _lastKnownToken != null &&
          _lastSyncedUid == user.uid) {
        _log(
          'refreshTokenNow: permission and token unchanged',
        );
        return;
      }

      final allowed =
          status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;

      if (!allowed) {
        _log(
          'refreshTokenNow: permission not granted',
        );
        _lastAuthStatus = status;
        return;
      }

      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb
            ? NotificationCredentials.fcmApiKey
            : null,
      );

      if (token == null || token.isEmpty) {
        _log(
          'refreshTokenNow: token null or empty',
        );
        return;
      }

      if (token == _lastKnownToken &&
          _lastSyncedUid == user.uid) {
        _lastAuthStatus = status;
        _log(
          'refreshTokenNow: token unchanged, skipping write',
        );
        return;
      }

      await _persistToken(token);
      _lastAuthStatus = status;
    } catch (e, st) {
      _log('refreshTokenNow ERROR => $e');
      _log('$st');
    }
  }

  // ============================================================
  // SAVE FCM TOKEN TO FIRESTORE
  // ============================================================

  static Future<void> _persistToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _log(
        '_persistToken: no user logged in, '
        'skipping Firestore write',
      );

      await NotificationSharedService
          .storePnsDeviceToken(token);

      return;
    }

    try {
      final uid = user.uid;

      _log(
        'Saving token to '
        '${ServerConfig.usersCollection}/$uid',
      );

     await _usersCollection.doc(uid).set({
  'pushToken': token,
}, SetOptions(merge: true));

      // Mark as synced only after successful write.
      _lastKnownToken = token;
      _lastSyncedUid = uid;

      _log(
        'Firestore pushToken updated successfully',
      );
    } on FirebaseException catch (e, st) {
      _log(
        '_persistToken Firestore ERROR => '
        '${e.code}: ${e.message}',
      );
      _log('$st');
    } catch (e, st) {
      _log('_persistToken ERROR => $e');
      _log('$st');
    }

    // Preserve existing local token storage.
    await NotificationSharedService
        .storePnsDeviceToken(token);
  }

  // ============================================================
  // INITIALIZE FCM TOKEN
  // ============================================================

  static Future<void> initializeToken() async {
    try {
      if (!kIsWeb) {
        await permissionEnabler();
      } else {
        final settings =
            await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus !=
            AuthorizationStatus.authorized) {
          _log(
            'Web notification permission not granted',
          );
          return;
        }
      }

      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb
            ? NotificationCredentials.fcmApiKey
            : null,
      );

      if (token == null || token.isEmpty) {
        _log('FCM token unavailable');
        return;
      }

      // Avoid printing the full device token.
      _log('FCM token generated successfully');

      await _persistToken(token);
    } catch (e, st) {
      _log('FCM TOKEN ERROR => $e');
      _log('$st');
    }
  }

  // ============================================================
  // NOTIFICATION PERMISSION
  // ============================================================

  static Future<void> permissionEnabler() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ============================================================
  // NOTIFICATION LISTENERS
  // ============================================================

  static Future<void> initializeNotificationListeners() async {
    // Background notification tapped.
    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessage,
    );

    // Foreground notification.
    FirebaseMessaging.onMessage.listen((message) {
      _log(
        'Foreground message: ${message.data}',
      );

      if (message.data['type'] == 'incoming_call' ||
          message.data['type'] == 'group_call') {
        if (!kIsWeb) {
          // Existing CallKit integration can be enabled here.
        }

        _log(
          'Call notification: ${message.data}',
        );
        return;
      }

      final notification = message.notification;

      if (notification == null) return;

      if (!NotificationRouteGuard
          .allowForegroundNotification) {
        return;
      }

      final notifType =
          message.data['type'] as String?;

      final notifRoute =
          message.data['route'] as String?;

      if (_shouldSuppress(
        currentRoute: CurrentRouteTracker.currentRoute,
        notifRoute: notifRoute,
        notifType: notifType,
      )) {
        return;
      }

      final context = rootNavKey.currentContext;
      if (context == null) {
        _log(
          'Navigator context unavailable, '
          'skipping overlay',
        );
        return;
      }

      InAppOverlayNotification.show(
        context: context,
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        onOpen: () => _handleMessage(message),
      );
    });
  }

  // ============================================================
  // SUPPRESS NOTIFICATIONS BASED ON CURRENT ROUTE
  // ============================================================

  static bool _shouldSuppress({
    required String currentRoute,
    required String? notifRoute,
    required String? notifType,
  }) {
    final basePath = Uri.parse(currentRoute).path;

    // Suppress chat notifications while in Messages.
    if (basePath == RouterPath.message &&
        (notifRoute == 'chat' ||
            notifRoute == 'message' ||
            notifType == 'chat' ||
            notifType == 'message')) {
      return true;
    }

    // Suppress connection notifications.
    if (basePath == RouterPath.connections &&
        (notifRoute == 'connection' ||
            notifType == 'connection')) {
      return true;
    }

    // Suppress direct message notifications.
    if (basePath == RouterPath.directMessage ||
        (basePath == RouterPath.directMessageTeams &&
            (notifRoute == 'chat' ||
                notifType == 'normal'))) {
      return true;
    }

    return false;
  }

  // ============================================================
  // MAIN NOTIFICATION HANDLER
  // ============================================================

  static void _handleMessage(RemoteMessage message) {
    final data = message.data;

    if (data.isEmpty) return;

    _log('Handling message: $data');

    if (data['type'] == 'incoming_call' ||
        data['type'] == 'group_call') {
      _log('Call notification received');
      return;
    }

    _handleNavigation(data);
  }

  // ============================================================
  // PLATFORM MAPPING
  // ============================================================

  static String getPlatformMapper() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        if (kIsWeb) {
          return NotificationPlatformKey.browser;
        }
        return NotificationPlatformKey.windows;

      case TargetPlatform.macOS:
        if (kIsWeb) {
          return NotificationPlatformKey.browser;
        }
        return NotificationPlatformKey.macOS;

      case TargetPlatform.android:
        return NotificationPlatformKey.android;

      case TargetPlatform.iOS:
        return NotificationPlatformKey.iOS;

      default:
        return NotificationPlatformKey.none;
    }
  }

  // ============================================================
  // NOTIFICATION NAVIGATION
  // ============================================================

  static void _handleNavigation(
    Map<String, dynamic> data,
  ) {
    final route =
        data['route'] ?? data['click_action'];

    final notifType =
        data['type'] as String?;

    final notifRoute =
        data['route'] as String?;

    if (_shouldSuppress(
      currentRoute: CurrentRouteTracker.currentRoute,
      notifRoute: notifRoute,
      notifType: notifType,
    )) {
      _log(
        'Navigation suppressed for route=$route '
        'on ${CurrentRouteTracker.currentRoute}',
      );
      return;
    }

    NotificationNavigationHandler.handle(
      data,
      route,
    );
  }
}
