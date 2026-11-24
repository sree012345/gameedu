import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_edu/core/config/server_config.dart';
import 'package:game_edu/student_module/classes/models/lesson_model.dart';
import '../models/lesson.dart';

class ClassDetailFailure implements Exception {
  const ClassDetailFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Lessons of a class, their materials / assignments and the user's progress.
///
///  * lessons   : `${env}_classes/{classId}/lessons/{lessonId}`
///                  (+ optional array field `materials`)
///  * questions : `${env}_classes/{classId}/lessons/{lessonId}/questions/{id}`
///  * progress  : `${env}_users/{uid}/class_progress/{classId}`
///      {
///        userId, classId,
///        completedLessonIds: [lessonId, ...],          // video watched
///        completedAt: { lessonId: <timestamp> },
///        assignments: {                                // assignment marks
///          lessonId: { score, total, percent, answers: {qId: index}, submittedAt }
///        },
///        updatedAt
///      }
class ClassDetailService {
  ClassDetailService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _lessonsCollection = 'lessons';
  static const String _questionsCollection = 'questions';
  static const String _progressCollection = 'class_progress';

  /// The logged-in user. Progress is always saved under this user's uid.
  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ClassDetailFailure(
        'Session expired. Please login again.',
        code: 'no-user',
      );
    }
    return user;
  }

  DocumentReference<Map<String, dynamic>> _progressDoc(
    String uid,
    String classId,
  ) => _firestore
      .collection(ServerConfig.usersCollection)
      .doc(uid)
      .collection(_progressCollection)
      .doc(classId);

  DocumentReference<Map<String, dynamic>> _lessonDoc(
    String classId,
    String lessonId,
  ) => _firestore
      .collection(ServerConfig.classesCollection)
      .doc(classId)
      .collection(_lessonsCollection)
      .doc(lessonId);

  // ───────────────────────── lessons ─────────────────────────

  /// Lessons sorted by `order` (missing order goes last).
  Future<List<Lesson>> fetchLessons(String classId) async {
    try {
      final snapshot = await _firestore
          .collection(ServerConfig.classesCollection)
          .doc(classId)
          .collection(_lessonsCollection)
          .get();

      final lessons = snapshot.docs.map(Lesson.fromDoc).toList()
        ..sort((a, b) {
          final byOrder = a.order.compareTo(b.order);
          return byOrder != 0 ? byOrder : a.title.compareTo(b.title);
        });
      return lessons;
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not load classes');
    }
  }

  // ───────────────────────── assignments ─────────────────────────

  /// Valid questions of one lesson, sorted by `order`.
  Future<List<AssignmentQuestion>> fetchQuestions(
    String classId,
    String lessonId,
  ) async {
    try {
      final snapshot = await _lessonDoc(
        classId,
        lessonId,
      ).collection(_questionsCollection).get();

      final questions = snapshot.docs
          .map(AssignmentQuestion.fromDoc)
          .where((q) => q.isValid)
          .toList()
        ..sort((a, b) {
          final byOrder = a.order.compareTo(b.order);
          return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
        });
      return questions;
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not load the assignment');
    }
  }

  /// How many valid questions each lesson has (lessonId -> count).
  /// Used to know which lessons need an assignment before the next one opens.
  Future<Map<String, int>> fetchAssignmentCounts(
    String classId,
    List<Lesson> lessons,
  ) async {
    final entries = await Future.wait(
      lessons.map((lesson) async {
        final questions = await fetchQuestions(classId, lesson.id);
        return MapEntry(lesson.id, questions.length);
      }),
    );
    return Map<String, int>.fromEntries(entries);
  }

  /// Materials (from the lesson doc) + assignment questions of one lesson.
  Future<LessonExtras> fetchLessonExtras(
    String classId,
    String lessonId,
  ) async {
    final materials = <LessonMaterial>[];

    try {
      final doc = await _lessonDoc(classId, lessonId).get();
      final raw = doc.data()?['materials'];

      if (raw is List) {
        for (final item in raw) {
          LessonMaterial? material;
          if (item is Map) {
            material = LessonMaterial.fromMap(Map<String, dynamic>.from(item));
          } else if (item is String) {
            material = LessonMaterial.fromMap({'url': item});
          }
          if (material != null && material.isValid) materials.add(material);
        }
      }
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not load this class');
    }

    final questions = await fetchQuestions(classId, lessonId);
    return LessonExtras(materials: materials, questions: questions);
  }

  // ───────────────────────── progress ─────────────────────────

  /// Progress of the logged-in user in this class.
  /// A read error is reported (not hidden), so progress never looks lost.
  Future<ClassProgress> fetchProgress(String classId) async {
    final user = _requireUser();

    try {
      final doc = await _progressDoc(user.uid, classId).get();
      final data = doc.data();
      if (data == null) return const ClassProgress();

      final list = data['completedLessonIds'];
      final completed = list is List
          ? list.map((e) => e.toString()).toSet()
          : <String>{};

      final results = <String, AssignmentResult>{};
      final rawResults = data['assignments'];
      if (rawResults is Map) {
        rawResults.forEach((key, value) {
          if (value is Map) {
            results[key.toString()] = AssignmentResult.fromMap(
              Map<String, dynamic>.from(value),
            );
          }
        });
      }

      return ClassProgress(completedIds: completed, results: results);
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not load your progress');
    }
  }

  /// Marks ONE lesson video as completed for the logged-in user.
  /// `arrayUnion` only adds, so it never wipes progress from another device.
  Future<void> markLessonCompleted(String classId, String lessonId) async {
    final user = _requireUser();

    try {
      await _progressDoc(user.uid, classId).set({
        'userId': user.uid,
        'classId': classId,
        'completedLessonIds': FieldValue.arrayUnion([lessonId]),
        'completedAt': {lessonId: FieldValue.serverTimestamp()},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not save your progress');
    }
  }

  /// Saves the assignment marks + answers for the logged-in user.
  Future<void> saveAssignmentResult(
    String classId,
    String lessonId,
    AssignmentResult result,
  ) async {
    final user = _requireUser();

    try {
      await _progressDoc(user.uid, classId).set({
        'userId': user.uid,
        'classId': classId,
        'assignments': {lessonId: result.toMap()},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not save your assignment');
    }
  }

  ClassDetailFailure _map(FirebaseException e, String fallback) {
    switch (e.code) {
      case 'permission-denied':
        return ClassDetailFailure(
          'You do not have permission to do this',
          code: e.code,
        );
      case 'unavailable':
      case 'network-request-failed':
        return ClassDetailFailure('No internet connection', code: e.code);
      default:
        return ClassDetailFailure(fallback, code: e.code);
    }
  }
}