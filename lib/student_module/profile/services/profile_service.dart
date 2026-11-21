import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_edu/core/config/server_config.dart';
import 'package:game_edu/core/storage_method/upload_storage_methods.dart';
import 'package:game_edu/student_module/create_profile/models/user_profile.dart';

class ProfileServiceFailure implements Exception {
  const ProfileServiceFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Get + update the signed-in user's profile (`${env}_users/{uid}`).
class ProfileService {
  ProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    UploadStorageMethods? uploader,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _uploader = uploader ?? UploadStorageMethods();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final UploadStorageMethods _uploader;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(ServerConfig.usersCollection).doc(uid);

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ProfileServiceFailure(
        'Session expired. Please login again.',
        code: 'no-user',
      );
    }
    return user;
  }

  /// Firestore data (FirebaseAuth fills any missing name / email / phone).
  Future<UserProfile> getProfile() async {
    final user = _requireUser();

    try {
      final doc = await _doc(user.uid).get();
      return UserProfile.fromSources(user, doc.data());
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not load your profile');
    }
  }

  /// Uploads the new photo and returns its download URL.
  Future<String> uploadPhoto(Uint8List bytes) async {
    final user = _requireUser();

    try {
      return await _uploader.uploadImageToStorage(
        '${ServerConfig.environment.name}_profile_photos/${user.uid}',
        bytes,
      );
    } on Exception catch (e) {
      throw ProfileServiceFailure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Updates the editable fields. [email] / [phone] are only passed when the
  /// user had none (a saved email / phone is never changed here).
  Future<void> updateProfile(
    UserProfile profile, {
    String? photoUrl,
    String? email,
    String? phone,
  }) async {
    final user = _requireUser();

    try {
      await _doc(user.uid).set({
        'fullName': profile.fullName,
        'gender': profile.gender?.value,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'college': profile.college,
        'department': profile.department,
        'yearOfStudy': profile.yearOfStudy,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not update your profile');
    }

    // Keep the Auth display name in sync (not critical).
    try {
      await user.updateDisplayName(profile.fullName);
    } catch (_) {}
  }

  ProfileServiceFailure _map(FirebaseException e, String fallback) {
    switch (e.code) {
      case 'permission-denied':
        return ProfileServiceFailure(
          'You do not have permission to do this',
          code: e.code,
        );
      case 'unavailable':
      case 'network-request-failed':
        return ProfileServiceFailure('No internet connection', code: e.code);
      default:
        return ProfileServiceFailure(fallback, code: e.code);
    }
  }
}
