import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/student_module/classes/models/lesson_model.dart';
import '../services/class_detail_service.dart';
part 'lesson_event.dart';
part 'lesson_state.dart';

/// One class page: study materials, video completion and the assignment.
class LessonBloc extends Bloc<LessonEvent, LessonState> {
  LessonBloc({
    required ClassDetailService service,
    required String classId,
    required String lessonId,
    required bool videoDone,
    AssignmentResult? result,
  }) : _service = service,
       _classId = classId,
       _lessonId = lessonId,
       super(
         LessonState(
           videoDone: videoDone,
           result: result,
           answers: result?.answers ?? const {},
         ),
       ) {
    on<LessonStarted>(_onStarted);
    on<LessonVideoFinished>(_onVideoFinished);
    on<AnswerSelected>(_onAnswerSelected);
    on<AssignmentSubmitted>(_onSubmitted);
  }

  final ClassDetailService _service;
  final String _classId;
  final String _lessonId;

  Future<void> _onStarted(
    LessonStarted event,
    Emitter<LessonState> emit,
  ) async {
    emit(state.copyWith(status: LessonStatus.loading, clearError: true));

    try {
      final extras = await _service.fetchLessonExtras(_classId, _lessonId);
      if (emit.isDone) return;

      emit(
        state.copyWith(
          status: LessonStatus.loaded,
          materials: extras.materials,
          questions: extras.questions,
        ),
      );
    } on ClassDetailFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: LessonStatus.failure, error: e.message));
    }
  }

  /// The video reached the end: open the assignment and save it for the user.
  Future<void> _onVideoFinished(
    LessonVideoFinished event,
    Emitter<LessonState> emit,
  ) async {
    if (state.videoDone) return; // already saved earlier

    emit(state.copyWith(videoDone: true));

    try {
      await _service.markLessonCompleted(_classId, _lessonId);
    } on ClassDetailFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(videoDone: false));
      _showMessage(
        emit,
        '${e.message}. Please open this class again and watch the video to the end.',
      );
    }
  }

  void _onAnswerSelected(AnswerSelected event, Emitter<LessonState> emit) {
    if (!state.videoDone || state.isSubmitted || state.submitting) return;

    final next = Map<String, int>.of(state.answers)
      ..[event.questionId] = event.optionIndex;
    emit(state.copyWith(answers: next));
  }

  Future<void> _onSubmitted(
    AssignmentSubmitted event,
    Emitter<LessonState> emit,
  ) async {
    if (state.submitting || state.isSubmitted) return;
    if (!state.videoDone || !state.allAnswered) return;

    emit(state.copyWith(submitting: true));

    final result = AssignmentResult.evaluate(state.questions, state.answers);

    try {
      await _service.saveAssignmentResult(_classId, _lessonId, result);
      if (emit.isDone) return;
      emit(state.copyWith(submitting: false, result: result));
    } on ClassDetailFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(submitting: false));
      _showMessage(emit, e.message);
    }
  }

  void _showMessage(Emitter<LessonState> emit, String message) {
    emit(state.copyWith(message: message));
    emit(state.copyWith(clearMessage: true));
  }
}