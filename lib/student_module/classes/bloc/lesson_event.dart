part of 'lesson_bloc.dart';

sealed class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

/// Load the study materials and the assignment questions.
final class LessonStarted extends LessonEvent {
  const LessonStarted();
}

/// The video reached the end.
final class LessonVideoFinished extends LessonEvent {
  const LessonVideoFinished();
}

/// The student tapped an option of a question.
final class AnswerSelected extends LessonEvent {
  const AnswerSelected(this.questionId, this.optionIndex);

  final String questionId;
  final int optionIndex;

  @override
  List<Object?> get props => [questionId, optionIndex];
}

/// The student submitted the assignment (marks are calculated and saved).
final class AssignmentSubmitted extends LessonEvent {
  const AssignmentSubmitted();
}