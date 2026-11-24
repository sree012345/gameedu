import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

int _asInt(Object? value, int fallback) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

/// Study material of a class (PDF, doc, ppt, xls or any link).
///
/// Stored in the lesson doc as an array field `materials`:
///   [ { title: "Class notes", url: "https://....pdf", type: "pdf" } ]
/// `url` can also be a Firebase Storage path or gs:// link.
/// `type` is optional (pdf | doc | ppt | xls | link). It is guessed from the url.
class LessonMaterial extends Equatable {
  const LessonMaterial({
    required this.title,
    required this.url,
    required this.type,
  });

  final String title;
  final String url;
  final String type;

  bool get isValid => url.trim().isNotEmpty;

  static String _guessType(String url) {
    final path = url.toLowerCase().split('?').first;
    if (path.endsWith('.pdf')) return 'pdf';
    if (path.endsWith('.doc') || path.endsWith('.docx')) return 'doc';
    if (path.endsWith('.ppt') || path.endsWith('.pptx')) return 'ppt';
    if (path.endsWith('.xls') ||
        path.endsWith('.xlsx') ||
        path.endsWith('.csv')) {
      return 'xls';
    }
    return 'link';
  }

  factory LessonMaterial.fromMap(Map<String, dynamic> map) {
    final url = (map['url'] ?? '').toString().trim();
    final title = (map['title'] ?? '').toString().trim();
    final type = (map['type'] ?? '').toString().trim().toLowerCase();

    return LessonMaterial(
      title: title.isEmpty ? 'Study material' : title,
      url: url,
      type: type.isEmpty ? _guessType(url) : type,
    );
  }

  @override
  List<Object?> get props => [title, url, type];
}

/// One multiple-choice question.
///
/// Stored as a document in
///   `${env}_classes/{classId}/lessons/{lessonId}/questions/{questionId}`
///   {
///     question:     "What is a game loop?",
///     options:      ["Option A", "Option B", "Option C", "Option D"],
///     correctIndex: 1,      // 0 = first option, 1 = second ...
///     marks:        1,      // optional, default 1
///     order:        1,      // optional, for sorting
///   }
class AssignmentQuestion extends Equatable {
  const AssignmentQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.marks = 1,
    this.order = 0,
  });

  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final int marks;
  final int order;

  /// A question without text, with fewer than 2 options or with a wrong
  /// `correctIndex` is skipped (so a student never gets stuck on it).
  bool get isValid =>
      text.trim().isNotEmpty &&
      options.length >= 2 &&
      correctIndex >= 0 &&
      correctIndex < options.length;

  factory AssignmentQuestion.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final rawOptions = data['options'];
    final options = rawOptions is List
        ? rawOptions.map((e) => e.toString()).toList()
        : <String>[];

    final marks = _asInt(data['marks'], 1);

    return AssignmentQuestion(
      id: doc.id,
      text: (data['question'] ?? '').toString(),
      options: options,
      correctIndex: _asInt(data['correctIndex'], -1),
      marks: marks < 0 ? 1 : marks,
      order: _asInt(data['order'], 0),
    );
  }

  @override
  List<Object?> get props => [id, text, options, correctIndex, marks, order];
}

/// What the student scored. Saved inside the progress doc:
///   assignments.{lessonId} = { score, total, percent, answers, submittedAt }
class AssignmentResult extends Equatable {
  const AssignmentResult({
    required this.score,
    required this.total,
    required this.answers,
    this.submittedAt,
  });

  final int score;
  final int total;

  /// questionId -> selected option index
  final Map<String, int> answers;
  final DateTime? submittedAt;

  int get percent => total == 0 ? 0 : (score * 100 / total).round();

  factory AssignmentResult.evaluate(
    List<AssignmentQuestion> questions,
    Map<String, int> answers,
  ) {
    var score = 0;
    var total = 0;

    for (final q in questions) {
      total += q.marks;
      if (answers[q.id] == q.correctIndex) score += q.marks;
    }

    return AssignmentResult(
      score: score,
      total: total,
      answers: Map<String, int>.of(answers),
    );
  }

  Map<String, dynamic> toMap() => {
    'score': score,
    'total': total,
    'percent': percent,
    'answers': answers,
    'submittedAt': FieldValue.serverTimestamp(),
  };

  factory AssignmentResult.fromMap(Map<String, dynamic> map) {
    final rawAnswers = map['answers'];
    final answers = <String, int>{};

    if (rawAnswers is Map) {
      rawAnswers.forEach((key, value) {
        final index = _asInt(value, -1);
        if (index >= 0) answers[key.toString()] = index;
      });
    }

    final submitted = map['submittedAt'];

    return AssignmentResult(
      score: _asInt(map['score'], 0),
      total: _asInt(map['total'], 0),
      answers: answers,
      submittedAt: submitted is Timestamp ? submitted.toDate() : null,
    );
  }

  @override
  List<Object?> get props => [score, total, answers, submittedAt];
}

/// The user's progress in one class (course):
///  * completedIds : lessons whose video was watched to the end
///  * results      : assignment results by lesson id
class ClassProgress extends Equatable {
  const ClassProgress({
    this.completedIds = const <String>{},
    this.results = const <String, AssignmentResult>{},
  });

  final Set<String> completedIds;
  final Map<String, AssignmentResult> results;

  @override
  List<Object?> get props => [completedIds, results];
}

/// Materials + assignment questions of one lesson.
class LessonExtras {
  const LessonExtras({
    this.materials = const <LessonMaterial>[],
    this.questions = const <AssignmentQuestion>[],
  });

  final List<LessonMaterial> materials;
  final List<AssignmentQuestion> questions;
}