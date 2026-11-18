/*
 * -----------------------------------------------------------------------------
 * File         : lib/core/push_notification/notification_platform_initializer.dart
 * Description  : Responsible for performing Notification dependencies integration on app start with firebase authentication 
 * Author       : Revolution Games Private Limited
 * Created On   : 2025-10-04
 * Last Updated : 2025-10-04
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class        : NotificationService
 * Purpose      : To Perform the push notification dependency integration with help of firebase Authentication  
 * -----------------------------------------------------------------------------
 */


import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:game_edu/core/push_notification/in_app_overlay_notification.dart';
import 'package:game_edu/core/push_notification/notification_credentials.dart';
import 'package:game_edu/core/push_notification/notification_navigation_handler.dart';
import 'package:game_edu/core/push_notification/notification_shared_service.dart';
import 'package:game_edu/core/push_notification/params/current_route_track.dart';
import 'package:game_edu/core/push_notification/params/notification_platform_key_params.dart';
import 'package:game_edu/core/routes/router.dart';
import 'package:game_edu/main.dart';
import '../routes/router_path.dart';

///  REQUIRED: Background handler (handles killed state)
@pragma('vm:entry-point')
// Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   if (message.data['type'] == 'incoming_call' ||
//       message.data['type'] == 'group_call') {
//     await CallKitService.showIncomingCall(message.data);
//   }
// }

class NotificationService {
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _prefsSubscription;

  // 🔔 ADDED: live FCM token rotation listener (app-lifetime singleton)
  static StreamSubscription<String>? _tokenRefreshSubscription;

  // 🔔 ADDED: auth state listener so token gets (re)written on login and
  // cleared on logout, independent of whatever calls initializeToken().
  static StreamSubscription<User?>? _authSubscription;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔔 ADDED — optimistic cache for refreshTokenNow(). Lets us skip the
  // Firestore write entirely on a plain app resume where nothing actually
  // changed (permission status same + token same). Only a genuine change
  // (OS-level permission toggle, or Firebase rotating the token) triggers
  // a write. Populated by every successful _persistToken() call so it never
  // drifts out of sync with what's actually on Firestore.
  static AuthorizationStatus? _lastAuthStatus;
  static String? _lastKnownToken;

  /// Single point for all debug/log output in this file.
  static void _log(String message) {
    debugPrint('🔔 [NotificationService] $message');
  }

  ///  INIT
  static Future<void> init() async {
    await firebaseInitialize();
    await initializeToken();

    ///  Register background handler (VERY IMPORTANT)
    // FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    await initializeNotificationListeners();

    // 🔔 ADDED — start once, app-lifetime
    listenToTokenRefresh();
    listenToAuthForToken();
  }

  // ── ADDED ────────────────────────────────────────────────────────────
  // Fires when Firebase rotates the token on its own (reinstall, app data
  // clear, token expiry, etc). Writes straight to Firestore so the users
  // doc always has the latest token without waiting for app restart.
  static void listenToTokenRefresh() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen(
          (newToken) async {
            _log("onTokenRefresh -> $newToken");
            await _persistToken(newToken);
          },
          onError: (e, st) {
            _log("onTokenRefresh ERROR => $e");
            _log("$st");
          },
        );
  }

  // ── ADDED ────────────────────────────────────────────────────────────
  // Re-syncs the token whenever auth state changes:
  //  - user logs in  -> fetch + write current token immediately
  //  - user logs out -> clear pushToken field on that (now-stale) doc
  // This is independent of SessionListenerService in main.dart; it only
  // cares about the token, not session validity.
  static User? _lastKnownUid;

  static void listenToAuthForToken() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      if (user != null) {
        _log("Auth changed -> logged in (${user.uid}), syncing token");
        await refreshTokenNow();
      } else {
        _log("Auth changed -> logged out, clearing token reference");
        // Note: we intentionally do NOT try to write to the previous
        // user's doc here (security rules will reject it post-signout).
        // Clearing is instead handled explicitly via clearTokenOnLogout()
        // BEFORE FirebaseAuth.instance.signOut() is called — see below.
      }
    });
  }

  // ── ADDED ────────────────────────────────────────────────────────────
  // Call this BEFORE FirebaseAuth.instance.signOut() anywhere in the app
  // (manual logout, force logout, session-invalid logout) so the write
  // still has a valid, authenticated uid to target.
  static Future<void> clearTokenOnLogout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        "pushToken": FieldValue.delete(),
      });
      _log("Cleared pushToken for ${user.uid} on logout");
    } catch (e, st) {
      _log("clearTokenOnLogout ERROR => $e");
      _log("$st");
    }

    // 🔔 ADDED — reset the optimistic cache on logout so the next login
    // (possibly a different user) doesn't skip its first write by
    // mistakenly thinking "nothing changed".
    _lastAuthStatus = null;
    _lastKnownToken = null;
  }

  // ── ADDED ────────────────────────────────────────────────────────────
  // Call this from app lifecycle resume (mobile) or on dashboard/session
  // start (web). Covers the case where the user toggled OS-level
  // notification permission from system settings — there's no Firebase
  // event for that, so we re-check permission + re-fetch token manually.
  //
  // 🔔 CHANGED — made optimistic: on a plain resume where nothing actually
  // changed (same permission status, same token already on file), this
  // returns immediately without hitting Firestore. Only a genuine change
  // triggers getToken() + a write. Web should not be calling this at all
  // on lifecycle resume (see didChangeAppLifecycleState in main.dart) —
  // this guard is just defense-in-depth if it's ever called there directly.
  static Future<void> refreshTokenNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _log("refreshTokenNow: no user logged in, skipping");
      return;
    }

    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      // Optimistic short-circuit: permission unchanged since last check
      // and we already have a token on file -> nothing to do.
      if (settings.authorizationStatus == _lastAuthStatus &&
          _lastKnownToken != null) {
        _log(
          "refreshTokenNow: unchanged (${settings.authorizationStatus}), skipping",
        );
        return;
      }
      _lastAuthStatus = settings.authorizationStatus;

      final allowed =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!allowed) {
        _log("refreshTokenNow: permission not granted, skipping");
        return;
      }

      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb ? NotificationCredentials.fcmApiKey : null,
      );

      if (token == null || token.isEmpty) {
        _log("refreshTokenNow: token null/empty, skipping");
        return;
      }

      // 🔔 ADDED — token itself unchanged -> skip the Firestore write too.
      if (token == _lastKnownToken) {
        _log("refreshTokenNow: token unchanged, skipping Firestore write");
        return;
      }

      await _persistToken(token);
    } catch (e, st) {
      _log("refreshTokenNow ERROR => $e");
      _log("$st");
    }
  }

  // ── ADDED ────────────────────────────────────────────────────────────
  // Single write path — everything (initializeToken, onTokenRefresh,
  // refreshTokenNow) funnels through here so there's one source of truth
  // and Firestore + NotificationSharedService never drift apart.
  static Future<void> _persistToken(String token) async {
    // 🔔 ADDED — keep the optimistic cache in sync no matter which call
    // site triggered the write, so refreshTokenNow() never goes stale.
    _lastKnownToken = token;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _log("_persistToken: no user logged in, skipping Firestore write");
      // still cache it locally via shared service if that's device-scoped
      await NotificationSharedService.storePnsDeviceToken(token);
      return;
    }

    try {
      // Firestore: users/{uid}.pushToken
      await _firestore.collection('users').doc(user.uid).update({
        "pushToken": token,
      });
      _log("Firestore pushToken updated for ${user.uid}");
    } catch (e, st) {
      _log("_persistToken Firestore ERROR => $e");
      _log("$st");
    }

    // Keep existing local/shared-prefs storage in sync too.
    await NotificationSharedService.storePnsDeviceToken(token);
  }

  /// Call once the uid is known (e.g. right after login) so push/in-app
  /// gating reflects the signed-in user's saved preferences, and keeps
  /// updating live if they change a toggle on another device/session.
  // static void listenToPreferences(String uid) {
  //   _prefsSubscription?.cancel();
  //   _prefsSubscription = FirebaseFirestore.instance
  //       .collection('notificationPrefs')
  //       .doc(uid)
  //       .snapshots()
  //       .listen((doc) {
  //         final settings = doc.exists
  //             ? NotificationSettingsModel.fromMap(doc.data())
  //             : NotificationSettingsModel.defaults();
  //         NotificationPreferenceCache.update(settings);
  //       });
  // }

  /// Call on logout so a stale user's preferences don't leak into the next
  /// session and so we stop listening to a doc we can no longer read.
  // static Future<void> stopListeningToPreferences() async {
  //   await _prefsSubscription?.cancel();
  //   _prefsSubscription = null;
  //   NotificationPreferenceCache.clear();
  // }

  ///  Firebase Init
  static Future<void> firebaseInitialize() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: NotificationCredentials.firebaseCredential,
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  ///  Token
  static Future<void> initializeToken() async {
    // NOTE: we deliberately do NOT skip token registration when pushEnabled
    // is false. The FCM token is per-device, not per-notification-type —
    // deleting it would also block incoming_call/group_call/missed_call
    // delivery, which must never be suppressible. pushEnabled instead gates
    // display (see onMessage below); actual background/terminated-state
    // suppression of non-call push has to happen server-side by checking
    // this same notificationPrefs doc before sending.
    try {
      if (!kIsWeb) {
        await permissionEnabler();
      } else {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          _log("Web notification permission not granted");
          return;
        }
      }

      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb ? NotificationCredentials.fcmApiKey : null,
      );

      _log("FCM TOKEN => $token");

      if (token != null && token.isNotEmpty) {
        // 🔔 CHANGED: route through _persistToken so Firestore + shared
        // service both get updated from this single call site too.
        await _persistToken(token);
      }
    } catch (e, st) {
      _log("FCM TOKEN ERROR => $e");
      _log("$st");
    }
  }
  // static Future<void> initializeToken() async {
  //   if (!kIsWeb) {
  //     await permissionEnabler();
  //   } else {
  //     final settings = await FirebaseMessaging.instance.requestPermission(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );

  //     if (settings.authorizationStatus != AuthorizationStatus.authorized) {
  //       debugPrint("Web notification permission not granted");
  //       return;
  //     }
  //   }

  //   final token = await FirebaseMessaging.instance.getToken(
  //     vapidKey: kIsWeb ? NotificationCredentials.fcmApiKey : null,
  //   );

  //   await NotificationSharedService.storePnsDeviceToken(token ?? '');
  // }

  ///  Permissions
  static Future<void> permissionEnabler() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  ///  LISTENERS
  static Future<void> initializeNotificationListeners() async {
    ///  Terminated (cold start)
    // final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // if (initialMessage != null) {
    //   _handleMessage(initialMessage);
    // }

    ///  Background → tapped
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    ///  Foreground
    FirebaseMessaging.onMessage.listen((message) {
      _log("Foreground message: ${message.data}");

      if (message.data['type'] == 'incoming_call' ||
          message.data['type'] == 'group_call') {
        if (!kIsWeb) {
          // CallNavigationService.showIncomingCall(message.data);
        }

        _log("THE DATA MESSAGE ${message.data}");

        return;
      }

      //  Show in-app notification
      final notification = message.notification;
      if (notification == null) return;
      if (!NotificationRouteGuard.allowForegroundNotification) return;

      final notifType = message.data['type'] as String?;
      final notifRoute = message.data['route'] as String?;

      //  Respect the user's "push" and "in-app" toggles + per-category toggle
      //  (likes/comments/mentions/follows/connections) before we ever render
      //  the overlay. Calls never reach this point — they're handled and
      //  returned above, before this check.
      // if (!NotificationPreferenceCache.shouldShowInApp(notifType)) {
      //   _log('In-app notification suppressed by preference: type=$notifType');
      //   return;
      // }

      debugPrint("THE THING WE CAN DO MAN ${message.data} and the ${CurrentRouteTracker.currentRoute}");

      if (_shouldSuppress(
        currentRoute: CurrentRouteTracker.currentRoute,
        notifRoute: notifRoute,
        notifType: notifType,
      )) {
        return;
      }

      InAppOverlayNotification.show(
        context: rootNavKey.currentContext!,
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        onOpen: () => _handleMessage(message),
      );
    });
  }

  static bool _shouldSuppress({
    required String currentRoute,
    required String? notifRoute,
    required String? notifType,
  }) {
    final basePath = Uri.parse(currentRoute).path;

    // Suppress chat notifications while on Messages
    if (basePath == RouterPath.message &&
        (notifRoute == 'chat' ||
            notifRoute == 'message' ||
            notifType == 'chat' ||
            notifType == 'message')) {
      return true;
    }

    // Suppress connection notifications while on Connections
    if (basePath == RouterPath.connections &&
        (notifRoute == 'connection' || notifType == 'connection')) {
      return true;
    }

    if (basePath == RouterPath.directMessage ||
        basePath == RouterPath.directMessageTeams &&
            (notifRoute == 'chat' || notifType == 'normal')) {
      return true;
    }

    return false;
  }

  ///  MAIN HANDLER (unified)
  static void _handleMessage(RemoteMessage message) {
    final data = message.data;

    if (data.isEmpty) return;

    _log("Handling message: $data");

    if (data['type'] == 'incoming_call' || data['type'] == 'group_call') {
      // CallKitService.showIncomingCall(message.data);
      // CallNavigationService.showIncomingCall(data);
      _log("THE DATA MESSAGE ${message.data}");

      return;
    }

    _handleNavigation(data);
  }

  static String getPlatformMapper() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        if (kIsWeb) return NotificationPlatformKey.browser;
        return NotificationPlatformKey.windows;
      case TargetPlatform.macOS:
        if (kIsWeb) return NotificationPlatformKey.browser;
        return NotificationPlatformKey.macOS;
      case TargetPlatform.android:
        return NotificationPlatformKey.android;
      case TargetPlatform.iOS:
        return NotificationPlatformKey.iOS;
      default:
        return NotificationPlatformKey.none;
    }
  }

  ///  CALLKIT
  // static Future<void> showCallkitIncoming(Map<String, dynamic> data) async {
  //   print(" Showing CallKit");
  //   print(" Raw data: $data");

  //   //  Parse payload safely
  //   Map<String, dynamic> payload = {};
  //   try {
  //     if (data['payload'] != null && data['payload'].toString().isNotEmpty) {
  //       payload = jsonDecode(data['payload']);
  //     }
  //   } catch (e) {
  //     print(" Payload parse error: $e");
  //   }

  //   final String callId = data['room_id'] ?? DateTime.now().toString();
  //   final String callerName = data['caller_name'] ?? "Unknown";
  //   final int callType = data['call_type'] == 'video' ? 1 : 0;

  //   await FlutterCallkitIncoming.showCallkitIncoming(
  //     CallKitParams(
  //       id: callId,
  //       nameCaller: callerName,
  //       appName: "Esport Circle",
  //       handle: callerName,
  //       type: callType,

  //       //  IMPORTANT: pass payload here
  //       extra: payload,

  //       // optional but recommended
  //       duration: 30000,
  //       textAccept: "Accept",
  //       textDecline: "Decline",
  //       android: const AndroidParams(
  //         isCustomNotification: true,
  //         isShowLogo: true,
  //         ringtonePath: 'system_ringtone_default',
  //       ),
  //       ios: const IOSParams(supportsVideo: true),
  //     ),
  //   );
  // }
  // static Future<void> showCallkitIncoming(Map<String, dynamic> data) async {
  //   print(" Showing CallKit");

  //   Map<String, dynamic> payload = {};
  //   try {
  //     if (data['payload'] != null) {
  //       payload = jsonDecode(data['payload']);
  //     }
  //   } catch (_) {}

  //   await FlutterCallkitIncoming.showCallkitIncoming(
  //     CallKitParams(
  //       id: data['room_id'] ?? DateTime.now().toString(),
  //       nameCaller: data['caller_name'] ?? "Unknown",
  //       appName: "Your App",
  //       handle: data['caller_name'],
  //       type: data['call_type'] == 'video' ? 1 : 0,
  //       extra: payload,
  //       duration: 30000,
  //       textAccept: "Accept",
  //       textDecline: "Decline",
  //     ),
  //   );
  // }

  /// 🔥 NAVIGATION
  static void _handleNavigation(Map<String, dynamic> data) {
    final route = data['route'] ?? data['click_action'];

    // ✅ Apply suppress check here too — covers iOS notification banner taps
    // (onMessageOpenedApp path), not just foreground onMessage.
    final notifType = data['type'] as String?;
    final notifRoute = data['route'] as String?;

    debugPrint("THE THING WE CAN DO MAN ${data} and the ${CurrentRouteTracker.currentRoute}");

    if (_shouldSuppress(
      currentRoute: CurrentRouteTracker.currentRoute,
      notifRoute: notifRoute,
      notifType: notifType,
    )) {
      _log(
        'Navigation suppressed for route=$route on ${CurrentRouteTracker.currentRoute}',
      );
      return;
    }

    NotificationNavigationHandler.handle(data, route);
  }
}