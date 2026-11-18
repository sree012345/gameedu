import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _deviceIdKey = 'device_id';
  static const _currentSessionIdKey = 'currentSessionId';
  static const _hasLaunchedKey = 'has_launched';

  /// Save device ID
  static Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }

  /// Get device ID
  static Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  /// Save current session ID (the session the user is currently using)
  static Future<void> saveCurrentSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentSessionIdKey, sessionId);
  }

  /// Get current session ID
  static Future<String?> getCurrentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentSessionIdKey);
  }

  /// Remove current session ID (on logout)
  static Future<void> removeCurrentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentSessionIdKey);
  }

  /// Check if app has launched before (for fresh install detection)
  static Future<bool> hasLaunchedBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasLaunchedKey) ?? false;
  }

  /// Set has launched flag (after first launch)
  static Future<void> setHasLaunched(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasLaunchedKey, value);
  }

  /// Clear all session-related data (on full logout)
  static Future<void> clearAllSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_currentSessionIdKey);
    // Don't remove _hasLaunchedKey as it's for install detection
  }
}
