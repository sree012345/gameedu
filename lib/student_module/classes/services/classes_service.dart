import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_edu/core/config/server_config.dart';

import '../models/class_item.dart';

class ClassesFailure implements Exception {
  const ClassesFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Reads the classes collection (`ServerConfig.classesCollection`).
class ClassesService {
  ClassesService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Upcoming + live classes this user may see, soonest first.
  ///  * audience general        -> everyone
  ///  * college-only classes    -> only users of that college
  Future<List<ClassItem>> fetchClasses() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ClassesFailure(
        'Session expired. Please login again.',
        code: 'no-user',
      );
    }

    // The user's college (saved at registration / profile)
    var userCollege = '';
    try {
      final doc = await _firestore
          .collection(ServerConfig.usersCollection)
          .doc(user.uid)
          .get();
      userCollege = (doc.data()?['college'] ?? '').toString().trim();
    } on FirebaseException {
      userCollege = '';
    }

    try {
      // Single-field range + orderBy: no composite index needed.
      final snapshot = await _firestore
          .collection(ServerConfig.classesCollection)
          .where('endsAt', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('endsAt')
          .get();

      final items = <ClassItem>[];
      for (final doc in snapshot.docs) {
        final item = ClassItem.tryFromDoc(doc);
        if (item != null && item.isVisibleTo(userCollege)) items.add(item);
      }

      items.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      return items;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw ClassesFailure(
            'You do not have permission to view classes',
            code: e.code,
          );
        case 'unavailable':
        case 'network-request-failed':
          throw ClassesFailure('No internet connection', code: e.code);
        default:
          throw ClassesFailure('Could not load classes', code: e.code);
      }
    }
  }
}
