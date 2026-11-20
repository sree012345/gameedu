import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_edu/core/config/server_config.dart';

import '../models/dashboard_user.dart';

/// Firebase calls used by the dashboard + left menu.
class DashboardService {
  DashboardService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Returns null when nobody is signed in.
  /// Reads `${env}_users/{uid}` (ServerConfig). If Firestore fails or the
  /// profile is missing, FirebaseAuth data is used so the screen still works.
  Future<DashboardUser?> loadUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    Map<String, dynamic>? data;
    try {
      final doc = await _firestore
          .collection(ServerConfig.usersCollection)
          .doc(user.uid)
          .get();
      data = doc.data();
    } on FirebaseException {
      data = null;
    }

    return DashboardUser.fromSources(user, data);
  }

  Future<void> signOut() => _auth.signOut();
}
