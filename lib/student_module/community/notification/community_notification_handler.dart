import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../community_config.dart';
import '../presentation/community_navigator.dart';

/// Glue between your EXISTING FCM / local-notification setup and the
/// Community feature. It does not initialise Firebase or request permissions –
/// call these helpers from the listeners you already have.
class CommunityNotificationHandler {
  CommunityNotificationHandler._();

  /// Set by the chat screen while it is open so that messages for the chat the
  /// user is already looking at do not produce a notification.
  static String? activeCommunityId;

  static const String _prefsKey = 'community_notified_message_ids';
  static const int _maxRemembered = 100;
  static final Set<String> _seen = <String>{};
  static bool _seeded = false;

  static bool isCommunityMessage(Map<String, dynamic> data) =>
      data['type'] == CommunityConfig.notificationType;

  /// Returns true only the first time a given message id is seen, so a
  /// message is never shown twice (retries, token duplicates, re-delivery).
  static Future<bool> claim(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_seeded) {
      _seen.addAll(prefs.getStringList(_prefsKey) ?? const <String>[]);
      _seeded = true;
    }
    if (!_seen.add(messageId)) return false;

    final list = _seen.toList();
    final trimmed =
        list.length > _maxRemembered ? list.sublist(list.length - _maxRemembered) : list;
    await prefs.setStringList(_prefsKey, trimmed);
    return true;
  }

  /// Call from `FirebaseMessaging.onMessage` (app in foreground).
  ///
  /// [showLocal] must display a notification with your existing local
  /// notification code. [id] is stable per message, so showing the same
  /// message twice replaces instead of duplicating.
  ///
  /// Returns true when the message belonged to Community (handled), so your
  /// existing handler can `return` early and not show it a second time.
  static Future<bool> onForegroundMessage(
    RemoteMessage message, {
    required Future<void> Function(
            int id, String title, String body, String payload)
        showLocal,
  }) async {
    final data = message.data;
    if (!isCommunityMessage(data)) return false;

    final communityId = data['communityId'] as String?;
    final messageId = data['messageId'] as String?;
    if (communityId == null || messageId == null) return true;

    if (communityId == activeCommunityId) return true;
    if (!await claim(messageId)) return true;

    final title = message.notification?.title ??
        (data['communityName'] as String?) ??
        'Community';
    final body =
        message.notification?.body ?? (data['preview'] as String?) ?? 'New message';

    await showLocal(_stableId(messageId), title, body, jsonEncode(data));
    return true;
  }

  /// Call from `onMessageOpenedApp`, `getInitialMessage()` and from your local
  /// notification tap callback (pass the decoded payload).
  /// Returns true when it was a Community notification.
  static bool handleTap(
    Map<String, dynamic> data,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    if (!isCommunityMessage(data)) return false;
    final communityId = data['communityId'] as String?;
    if (communityId == null) return true;

    // Wait for the first frame so this also works on a cold start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CommunityNavigator.openChatWithKey(navigatorKey, communityId);
    });
    return true;
  }

  /// Decodes the payload that [onForegroundMessage] gave to `showLocal`.
  static Map<String, dynamic>? decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  static int _stableId(String messageId) => messageId.hashCode & 0x7fffffff;
}
