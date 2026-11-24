part of 'class_detail_bloc.dart';

enum ClassDetailStatus { loading, loaded, failure }

final class ClassDetailState extends Equatable {
  const ClassDetailState({
    this.status = ClassDetailStatus.loading,
    this.lessons = const [],
    this.userProgress = const ClassProgress(),
    this.assignmentCounts = const {},
    this.error,
  });

  final ClassDetailStatus status;
  final List<Lesson> lessons;

  /// Videos watched + assignment results of the logged-in user.
  final ClassProgress userProgress;

  /// lessonId -> number of questions (0 = no assignment).
  final Map<String, int> assignmentCounts;
  final String? error;

  int get total => lessons.length;

  Set<String> get completedIds => userProgress.completedIds;

  bool hasAssignment(Lesson lesson) => (assignmentCounts[lesson.id] ?? 0) > 0;

  /// A class is DONE when its video was watched to the end AND, if it has an
  /// assignment, the assignment was submitted.
  ///
  /// (To unlock the next class after the video only, ignore the assignment
  ///  here: `return completedIds.contains(lesson.id);`)
  bool isLessonDone(Lesson lesson) {
    if (!completedIds.contains(lesson.id)) return false;
    if (!hasAssignment(lesson)) return true;
    return userProgress.results.containsKey(lesson.id);
  }

  /// Only classes that still exist are counted.
  int get completedCount => lessons.where(isLessonDone).length;

  double get progress => total == 0 ? 0 : completedCount / total;
  int get percent => (progress * 100).round();
  bool get isComplete => total > 0 && completedCount == total;

  /// Class 1 is always open. Class N needs class N-1 done.
  bool isUnlocked(int index) {
    if (index <= 0) return true;
    if (index >= lessons.length) return false;
    return isLessonDone(lessons[index - 1]);
  }

  ClassDetailState copyWith({
    ClassDetailStatus? status,
    List<Lesson>? lessons,
    ClassProgress? userProgress,
    Map<String, int>? assignmentCounts,
    String? error,
    bool clearError = false,
  }) {
    return ClassDetailState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      userProgress: userProgress ?? this.userProgress,
      assignmentCounts: assignmentCounts ?? this.assignmentCounts,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    lessons,
    userProgress,
    assignmentCounts,
    error,
  ];
}