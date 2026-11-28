
import 'package:game_edu/core/config/server_config.dart';

/// Central place to map the Community feature onto YOUR existing Firebase
/// schema. Collection names follow your `ServerConfig` environments
/// (dev_ / qa_ / staging_ / prod_).
class CommunityConfig {
  CommunityConfig._();

  // Firestore collections (environment prefixed, same as ServerConfig)
  static String get usersCollection => ServerConfig.usersCollection;
  static String get communitiesCollection =>
      '${ServerConfig.environment.name}_communities';

  /// Sub-collection inside each community document (no prefix needed).
  static const String messagesCollection = 'messages';

  // Fields on your existing `{env}_users/{uid}` document
  /// Name fields are tried in this order; the first non-empty one is used.
  /// Put the exact field of your users document FIRST (e.g. 'fullName').
  static const List<String> userNameFields = [
    'name',
    'fullName',
    'full_name',
    'displayName',
    'display_name',
    'userName',
    'username',
  ];

  /// If the user has no single name field, first + last name are joined.
  static const List<String> userFirstNameFields = ['firstName', 'first_name'];
  static const List<String> userLastNameFields = ['lastName', 'last_name'];

  /// Last-resort fallbacks shown when no name exists.
  static const List<String> userFallbackFields = ['email', 'phone', 'phoneNumber', 'mobile'];

  static const List<String> userPhotoFields = [
    'photoUrl',
    'photoURL',
    'profileImage',
    'profile_image',
    'profilePicture',
    'avatar',
    'imageUrl',
  ];

  /// Field that tells whether the logged-in user is an admin.
  /// Supports a string role (`role: 'admin'`) or a boolean (`isAdmin: true`).
  static const String userRoleField = 'role';
  static const String adminRoleValue = 'admin';
  static const String userIsAdminBoolField = 'isAdmin';

  // Storage root (also environment prefixed, e.g. dev_communities/{id}/...)
  static String get storageRoot => communitiesCollection;

  // Paging / limits
  static const int pageSize = 30;
  static const int maxImageBytes = 10 * 1024 * 1024;
  static const int maxVideoBytes = 100 * 1024 * 1024;
  static const int maxAudioBytes = 25 * 1024 * 1024;

  // Push notifications (must match functions/index.js)
  static const String notificationType = 'community_message';
  static const String notificationChannelId = 'community_messages';
  static const String notificationChannelName = 'Community messages';
}