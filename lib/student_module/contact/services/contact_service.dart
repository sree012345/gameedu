import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_edu/core/config/server_config.dart';

class ContactFailure implements Exception {
  const ContactFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Saves the messages of the "Contact Us" page in Firestore:
/// `${env}_support_messages/{id}`
///
///   uid, email, name, subject, message,
///   status ('new' -> 'open' -> 'closed', changed by your support team),
///   createdAt
class ContactService {
  ContactService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<void> sendMessage({
    required String subject,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ContactFailure('Please sign in again');
    }

    try {
      await _db
          .collection(ServerConfig.supportMessagesCollection)
          .add({
            'uid': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'subject': subject.trim(),
            'message': message.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          })
          // without internet Firestore would wait forever
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ContactFailure(
        'No internet connection. Please try again.',
      );
    } on FirebaseException catch (e) {
      throw ContactFailure(e.message ?? 'Could not send your message');
    }
  }
}
