import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/community_exception.dart';
import '../../data/models/community_user.dart';
import '../../data/services/community_firebase_service.dart';

part 'participant_picker_event.dart';
part 'participant_picker_state.dart';

class ParticipantPickerBloc
    extends Bloc<ParticipantPickerEvent, ParticipantPickerState> {
  ParticipantPickerBloc({required CommunityFirebaseService service})
      : _service = service,
        super(const ParticipantPickerState()) {
    on<ParticipantPickerStarted>(_onStarted);
    on<ParticipantPickerQueryChanged>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<ParticipantPickerToggled>(_onToggled);
  }

  final CommunityFirebaseService _service;

  Future<void> _onStarted(
    ParticipantPickerStarted event,
    Emitter<ParticipantPickerState> emit,
  ) async {
    emit(state.copyWith(
      status: ParticipantPickerStatus.loading,
      selectedIds: event.initialSelected,
    ));
    try {
      final users =
          await _service.getParticipantCandidates(excludeIds: event.excludeIds);
      emit(state.copyWith(status: ParticipantPickerStatus.success, users: users));
    } catch (error) {
      emit(state.copyWith(
        status: ParticipantPickerStatus.failure,
        errorMessage: CommunityException.messageOf(error),
      ));
    }
  }

  void _onToggled(
    ParticipantPickerToggled event,
    Emitter<ParticipantPickerState> emit,
  ) {
    final selected = Set<String>.from(state.selectedIds);
    if (!selected.add(event.userId)) selected.remove(event.userId);
    emit(state.copyWith(selectedIds: selected));
  }
}
