import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/class_item.dart';
import '../services/classes_service.dart';

part 'classes_event.dart';
part 'classes_state.dart';

/// Classes tab: loads from Firebase, then search / topic filter run
/// locally on the loaded list.
class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  ClassesBloc({required ClassesService service})
    : _service = service,
      super(const ClassesState()) {
    on<ClassesStarted>((e, emit) => _load(emit, showLoader: true));
    on<ClassesRefreshed>((e, emit) => _load(emit, showLoader: false));
    on<ClassesViewChanged>((e, emit) => emit(state.copyWith(view: e.view)));
    on<ClassesSearchChanged>((e, emit) => emit(state.copyWith(query: e.query)));
    on<ClassesTopicSelected>(
      (e, emit) => emit(
        e.topic == null
            ? state.copyWith(clearTopic: true)
            : state.copyWith(topic: e.topic),
      ),
    );
  }

  final ClassesService _service;

  Future<void> _load(
    Emitter<ClassesState> emit, {
    required bool showLoader,
  }) async {
    if (showLoader) {
      emit(state.copyWith(status: ClassesStatus.loading, clearError: true));
    } else {
      emit(state.copyWith(refreshing: true, clearError: true));
    }

    try {
      final items = await _service.fetchClasses();
      if (emit.isDone) return;

      // Keep the selected topic only if it still exists.
      final topics = {for (final c in items) c.topic};
      final keepTopic = state.topic != null && topics.contains(state.topic);

      emit(
        state.copyWith(
          status: ClassesStatus.loaded,
          items: items,
          refreshing: false,
          clearTopic: !keepTopic,
        ),
      );
    } on ClassesFailure catch (e) {
      if (emit.isDone) return;
      // A failed refresh keeps showing the old list.
      emit(
        state.copyWith(
          status: state.items.isEmpty
              ? ClassesStatus.failure
              : ClassesStatus.loaded,
          refreshing: false,
          error: e.message,
        ),
      );
    }
  }
}
