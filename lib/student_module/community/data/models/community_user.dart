import 'package:equatable/equatable.dart';

import '../../community_config.dart';

class CommunityUser extends Equatable {
  const CommunityUser({
    required this.id,
    required this.name,
    this.photoUrl,
    this.isAdmin = false,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final bool isAdmin;

  factory CommunityUser.fromMap(String id, Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};

    final role = map[CommunityConfig.userRoleField];
    final isAdminFlag = map[CommunityConfig.userIsAdminBoolField];
    final isAdmin = isAdminFlag == true ||
        role == true ||
        (role is String &&
            role.toLowerCase() == CommunityConfig.adminRoleValue.toLowerCase());

    return CommunityUser(
      id: id,
      name: _resolveName(map),
      photoUrl: _firstString(map, CommunityConfig.userPhotoFields),
      isAdmin: isAdmin,
    );
  }

  static String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static String _resolveName(Map<String, dynamic> map) {
    final single = _firstString(map, CommunityConfig.userNameFields);
    if (single != null) return single;

    final first = _firstString(map, CommunityConfig.userFirstNameFields);
    final last = _firstString(map, CommunityConfig.userLastNameFields);
    final joined = [first, last].whereType<String>().join(' ').trim();
    if (joined.isNotEmpty) return joined;

    final fallback = _firstString(map, CommunityConfig.userFallbackFields);
    if (fallback != null) return fallback;

    return 'User';
  }

  @override
  List<Object?> get props => [id, name, photoUrl, isAdmin];
}