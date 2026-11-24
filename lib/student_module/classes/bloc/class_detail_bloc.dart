import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/student_module/classes/models/lesson_model.dart';

import '../models/lesson.dart';
import '../services/class_detail_service.dart';

part 'class_detail_event.dart';
part 'class_detail_state.dart';

/// Class detail page: the list of classes (lessons) + the user's progress.
/// Playing the video / doing the assignment is handled by [LessonBloc].
class ClassDetailBloc extends Bloc<ClassDetailEvent, ClassDetailState> {
  ClassDetailBloc({
    required ClassDetailService service,
    required String classId,
  }) : _service = service,
       _classId = classId,
       super(const ClassDetailState()) {
    on<ClassDetailStarted>(_onStarted);
    on<ClassDetailRefreshed>(_onRefreshed);
  }

  final ClassDetailService _service;
  final String _classId;

  Future<void> _onStarted(
    ClassDetailStarted event,
    Emitter<ClassDetailState> emit,
  ) async {
    emit(state.copyWith(status: ClassDetailStatus.loading, clearError: true));

    try {
      final lessons = await _service.fetchLessons(_classId);

      // Progress + "which lessons have an assignment" together
      final results = await Future.wait<Object>([
        _service.fetchProgress(_classId),
        _service.fetchAssignmentCounts(_classId, lessons),
      ]);
      if (emit.isDone) return;

      emit(
        state.copyWith(
          status: ClassDetailStatus.loaded,
          lessons: lessons,
          userProgress: results[0] as ClassProgress,
          assignmentCounts: results[1] as Map<String, int>,
        ),
      );
    } on ClassDetailFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: ClassDetailStatus.failure, error: e.message));
    }
  }

  /// Called when the user comes back from a class page: re-reads progress
  /// quietly (no loader) so ticks, scores and unlocks are up to date.
  Future<void> _onRefreshed(
    ClassDetailRefreshed event,
    Emitter<ClassDetailState> emit,
  ) async {
    if (state.status != ClassDetailStatus.loaded) return;

    try {
      final progress = await _service.fetchProgress(_classId);
      if (emit.isDone) return;
      emit(state.copyWith(userProgress: progress));
    } on ClassDetailFailure {
      // Keep showing what we already have.
    }
  }
}