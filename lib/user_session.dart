
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:game_edu/core/config/server_config.dart';

class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  bool isAdmin = false;
  bool isReady = false;

  Future<void> init(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(ServerConfig.usersCollection)
          .doc(uid)
          .get();

      final data = doc.data();

      isAdmin = (data?['type'] ?? '').toString() == 'admin';
      isReady = true;

      debugPrint(
        "✅ [UserSession] Collection=${ServerConfig.usersCollection}, isAdmin=$isAdmin",
      );
    } catch (e) {
      isAdmin = false;
      isReady = false;
      debugPrint("❌ [UserSession] init failed: $e");
    }
  }

  void clear() {
    isAdmin = false;
    isReady = false;
    debugPrint("🧹 [UserSession] cleared");
  }
}
