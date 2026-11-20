import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:game_edu/core/config/server_config.dart';

/// Friendly error thrown by [FirebaseAuthService]. The bloc only deals
/// with this type, never with raw Firebase exceptions.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  bool get isInvalidOtp => code == 'invalid-verification-code';

  @override
  String toString() => message;
}

/// Result of "send OTP".
class PhoneOtpResult {
  const PhoneOtpResult({required this.verificationId, this.resendToken});

  final String verificationId;

  /// Pass back on resend so Firebase can reuse the session.
  final int? resendToken;
}

/// All Firebase calls for auth live here (email + password, phone OTP,
/// and saving the registration details to Firestore).
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  // ───────────────────────── Email + password ─────────────────────────

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _requireUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  Future<User> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _requireUser(result.user);
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  // ───────────────────────── Phone OTP ─────────────────────────

  /// Sends an SMS code to [phoneNumber] (E.164, e.g. +919876543210).
  /// Completes when Firebase says the code was sent (or failed).
  Future<PhoneOtpResult> sendOtp({
    required String phoneNumber,
    int? resendToken,
  }) async {
    final completer = Completer<PhoneOtpResult>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 60),
        // Android may auto-read the SMS. We still let the user confirm
        // with the OTP box, so nothing to do here.
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          if (!completer.isCompleted) completer.completeError(_map(e));
        },
        codeSent: (verificationId, token) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneOtpResult(verificationId: verificationId, resendToken: token),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!completer.isCompleted) {
            completer.complete(PhoneOtpResult(verificationId: verificationId));
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }

    return completer.future.timeout(
      const Duration(seconds: 70),
      onTimeout: () =>
          throw const AuthFailure('Request timed out. Please try again.'),
    );
  }

  Future<User> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      return _requireUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  // ───────────────────────── Profile ─────────────────────────

Future<void> saveUserProfile({
  required String uid,
  required String fullName,
  required String college,
  required String studentId,
  String? email,
  String? phone,
}) async {
  try {
    debugPrint('========== FIRESTORE SAVE START ==========');
    debugPrint('User UID: $uid');
    debugPrint('Collection: ${ServerConfig.usersCollection}');
    debugPrint('Auth UID: ${_auth.currentUser?.uid}');

    await _firestore.collection(ServerConfig.usersCollection).doc(uid).set({
      'fullName': fullName,
      'college': college,
      'studentId': studentId,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('✅ Firestore user saved successfully');
  } on FirebaseException catch (e) {
    debugPrint('❌ Firestore error code: ${e.code}');
    debugPrint('❌ Firestore error message: ${e.message}');

    throw AuthFailure(
      'Could not save your profile',
      code: e.code,
    );
  }
}

  Future<void> signOut() => _auth.signOut();

  // ───────────────────────── helpers ─────────────────────────

  User _requireUser(User? user) {
    if (user == null) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
    return user;
  }

  AuthFailure _map(FirebaseAuthException e) {
    final String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'Enter a valid email address';
      case 'user-disabled':
        message = 'This account has been disabled';
      case 'user-not-found':
        message = 'No account found. Please register first';
      case 'wrong-password':
      case 'invalid-credential':
        message = 'Incorrect email or password';
      case 'email-already-in-use':
        message = 'An account already exists with this email';
      case 'weak-password':
        message = 'Password is too weak';
      case 'invalid-phone-number':
        message = 'Enter a valid mobile number';
      case 'invalid-verification-code':
        message = 'Incorrect OTP. Please try again.';
      case 'session-expired':
      case 'code-expired':
        message = 'OTP expired. Please resend a new one';
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later';
      case 'quota-exceeded':
        message = 'SMS limit reached. Please try again later';
      case 'network-request-failed':
        message = 'No internet connection';
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled';
      default:
        message = e.message ?? 'Something went wrong. Please try again.';
    }
    return AuthFailure(message, code: e.code);
  }
}
