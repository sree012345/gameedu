import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:game_edu/core/config/server_config.dart';
import 'package:game_edu/core/routes/router_path.dart';

class StartupService {
  static const _lookupTimeout = Duration(seconds: 10);

  Future<String> resolveNextRoute({bool isRegistration = false}) async {
    final auth = FirebaseAuth.instance;
    debugPrint('[Startup] Waiting for Firebase Auth');

    final user = await auth.authStateChanges().timeout(
      _lookupTimeout,
      onTimeout: (sink) => sink.addError(
        FirebaseException(
          plugin: 'firebase_auth',
          code: 'deadline-exceeded',
          message: 'Timed out waiting for Firebase Auth.',
        ),
      ),
    ).first;
if (user == null) return RouterPath.loginStep;
    debugPrint('[Startup] Loading the Firestore profile');
    final profile = await FirebaseFirestore.instance
        .collection(ServerConfig.usersCollection)
        .doc(user.uid)
        .get(const GetOptions(source: Source.server))
        .timeout(
          _lookupTimeout,
          onTimeout: () => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'deadline-exceeded',
            message: 'Timed out loading the user profile.',
          ),
        );

    if (auth.currentUser?.uid != user.uid) {
      return RouterPath.authWrapper;
    }

    final data = profile.data();

    if (data == null) {
      if (isRegistration) return RouterPath.createProfile;

      await auth.signOut();
      return RouterPath.authWrapper;
    }

    final completed = !data.containsKey('onboardingCompleted') ||
        data['onboardingCompleted'] == true;

    return completed ? RouterPath.home : RouterPath.createProfile;
  }
}
