part of 'lesson_bloc.dart';

enum LessonStatus { loading, loaded, failure }

final class LessonState extends Equatable {
  const LessonState({
    this.status = LessonStatus.loading,
    this.materials = const [],
    this.questions = const [],
    this.answers = const {},
    this.watchedVideoIds = const {},
    this.videoDone = false,
    this.result,
    this.submitting = false,
    this.error,
    this.message,
  });

  final LessonStatus status;
  final List<LessonMaterial> materials;
  final List<AssignmentQuestion> questions;

  /// questionId -> selected option index
  final Map<String, int> answers;

  /// Ids of the videos watched to the end.
  final Set<String> watchedVideoIds;

  /// ALL videos of this lesson were watched (saved for this user).
  final bool videoDone;

  /// Set after the assignment is submitted.
  final AssignmentResult? result;
  final bool submitting;
  final String? error;

  /// One-shot snackbar text.
  final String? message;

  bool get hasAssignment => questions.isNotEmpty;
  bool get isSubmitted => result != null;

  int get answeredCount => questions.where((q) => answers.containsKey(q.id)).length;
  bool get allAnswered => hasAssignment && answeredCount == questions.length;
  int get totalMarks => questions.fold(0, (sum, q) => sum + q.marks);

  LessonState copyWith({
    LessonStatus? status,
    List<LessonMaterial>? materials,
    List<AssignmentQuestion>? questions,
    Map<String, int>? answers,
    Set<String>? watchedVideoIds,
    bool? videoDone,
    AssignmentResult? result,
    bool? submitting,
    String? error,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return LessonState(
      status: status ?? this.status,
      materials: materials ?? this.materials,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      watchedVideoIds: watchedVideoIds ?? this.watchedVideoIds,
      videoDone: videoDone ?? this.videoDone,
      result: result ?? this.result,
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    status,
    materials,
    questions,
    answers,
    watchedVideoIds,
    videoDone,
    result,
    submitting,
    error,
    message,
  ];
}