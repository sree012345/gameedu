// /*
//  * -----------------------------------------------------------------------------
//  * File         : lib/core/push_notification/notification_preference_cache.dart
//  * Description  : In-memory mirror of the user's NotificationSettingsModel,
//  *                kept live via a Firestore stream. Used purely to gate the
//  *                foreground in-app overlay — NOT to gate FCM token
//  *                registration, since the token is per-device and calls
//  *                (incoming_call/group_call/missed_call) must always be able
//  *                to reach the device regardless of these prefs.
//  * -----------------------------------------------------------------------------
//  */

// import 'package:flutter/foundation.dart';
// import 'package:revogram/e_sports_circle/notification/data/model/notification_setting_model.dart';

// class NotificationPreferenceCache {
//   NotificationPreferenceCache._();

//   static NotificationSettingsModel? _settings;

//   /// Single point for all debug output in this file — same pattern as
//   /// NotificationService._log, so every preference-related log line is
//   /// tagged consistently and easy to filter in the console.
//   static void _log(String message) {
//     debugPrint('🔔 [NotificationPrefs] $message');
//   }

//   /// Falls back to safe defaults (everything on) until the real prefs load,
//   /// so we never silently drop notifications before the first snapshot.
//   static NotificationSettingsModel get current =>
//       _settings ?? NotificationSettingsModel.defaults();

//   static bool get isLoaded => _settings != null;

//   static void update(NotificationSettingsModel settings) {
//     _settings = settings;
//     // Full dump of every field, not just a hand-picked subset — so you can
//     // always see exactly what the app thinks the user's preferences are
//     // the moment they change, straight from the Firestore snapshot.
//     _log('Preferences updated → ${settings.toMap()}');
//   }

//   static void clear() {
//     _log('Preferences cleared (logout)');
//     _settings = null;
//   }

//   /// Only the 5 "social" notification types have a dedicated per-category
//   /// toggle. Everything else (chat, liveStream, teams, member_request,
//   /// class_detail, fixture_detail, order, etc.) has no per-type toggle by
//   /// design — it rides purely on the two blanket switches below. Calls
//   /// (incoming_call/group_call/missed_call) never reach this check at all;
//   /// they're handled and returned before NotificationService gets here.
//   static bool _isCategoryEnabled(String? type) {
//     final s = current;
//     switch (type) {
//       case 'follow':
//         return s.newFollowers;
//       case 'like':
//         return s.likes;
//       case 'comment':
//         return s.comments;
//       case 'mention':
//         return s.mentions;
//       case 'connection':
//       case 'connection_request':
//         return s.connections;
//       default:
//         return true;
//     }
//   }

//   /// Should this notification render as an in-app overlay while the app is
//   /// in the foreground? Both blanket switches must be on, and — for the 5
//   /// social types only — the matching category switch must be on too.
//   /// Logs the full current cache state + the type it's checking + the
//   /// final verdict, so you can see exactly why something was shown or
//   /// suppressed without guessing.
//   static bool shouldShowInApp(String? type) {
//     final s = current;
//     final categoryOk = _isCategoryEnabled(type);
//     final allowed = s.pushEnabled && s.inAppEnabled && categoryOk;

//     _log(
//       'Gate check → type=$type | isLoaded=$isLoaded | '
//       'prefs=${s.toMap()} | categoryOk=$categoryOk | allowed=$allowed',
//     );

//     return allowed;
//   }
// }