import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:game_edu/core/config/server_config.dart';
import 'package:game_edu/core/storage_method/upload_storage_methods.dart';

import '../models/user_profile.dart';

class ProfileFailure implements Exception {
  const ProfileFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Firebase calls for the Create Profile flow.
/// Reads / updates `${env}_users/{uid}` through [ServerConfig].
class CreateProfileService {
  CreateProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(ServerConfig.usersCollection).doc(uid);

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ProfileFailure(
        'Session expired. Please login again.',
        code: 'no-user',
      );
    }
    return user;
  }

  /// Existing data (name + college saved at registration) used to pre-fill.
  /// If Firestore can't be read, FirebaseAuth data is used instead.
  Future<UserProfile> getProfile() async {
    final user = _requireUser();

    Map<String, dynamic>? data;
    try {
      data = (await _doc(user.uid).get()).data();
    } on FirebaseException {
      data = null;
    }
    return UserProfile.fromSources(user, data);
  }

  /// Uploads to `${env}_profile_photos/{uid}.jpg|png` and returns the URL.
Future<String> uploadPhoto({
  required Uint8List bytes,
  required String fileName,
}) async {
  final user = _requireUser();

  try {
    return await UploadStorageMethods().uploadImageToStorage(
      '${ServerConfig.environment.name}_profile_photos/${user.uid}',
      bytes,
    );
  } on FirebaseException catch (e) {
    throw _map(e, 'Could not upload your photo');
  } catch (e) {
    // UploadStorageMethods throws plain Exceptions
    throw ProfileFailure(e.toString().replaceFirst('Exception: ', ''));
  }
}

  /// Saves the profile and marks `onboardingCompleted: true`.
  Future<void> saveProfile(UserProfile profile, {String? photoUrl}) async {
    final user = _requireUser();

    try {
      await _doc(user.uid).set({
        'fullName': profile.fullName,
        'gender': profile.gender?.value,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'college': profile.college,
        'department': profile.department,
        'yearOfStudy': profile.yearOfStudy,
        'studentId': profile.studentId,
        'interests': profile.interests,
        'skillLevel': profile.skillLevel.value,
        'onboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not save your profile');
    }

    // Keep the Auth display name in sync (not critical).
    try {
      await user.updateDisplayName(profile.fullName);
    } catch (_) {}
  }

  /// "Skip": finish onboarding without the extra details.
  Future<void> skip() async {
    final user = _requireUser();

    try {
      await _doc(user.uid).set({
        'onboardingCompleted': true,
        'profileSkipped': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not skip right now. Please try again.');
    }
  }

  ProfileFailure _map(FirebaseException e, String fallback) {
    switch (e.code) {
      case 'permission-denied':
      case 'unauthorized':
        return ProfileFailure(
          'You do not have permission to do this',
          code: e.code,
        );
      case 'unavailable':
      case 'network-request-failed':
        return ProfileFailure('No internet connection', code: e.code);
      default:
        return ProfileFailure(fallback, code: e.code);
    }
  }
}
