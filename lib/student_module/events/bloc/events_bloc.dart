import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/event_item.dart';
import '../services/events_service.dart';

part 'events_event.dart';
part 'events_state.dart';

/// Events tab: loads events + the user's registrations and registers.
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc({required EventsService service})
    : _service = service,
      super(const EventsState()) {
    on<EventsStarted>((e, emit) => _load(emit, showLoader: true));
    on<EventsRefreshed>((e, emit) => _load(emit, showLoader: false));
    on<EventRegisterConfirmed>(_onRegister);
  }

  final EventsService _service;

  Future<void> _load(
    Emitter<EventsState> emit, {
    required bool showLoader,
  }) async {
    if (showLoader) {
      emit(state.copyWith(status: EventsStatus.loading, clearError: true));
    } else {
      emit(state.copyWith(refreshing: true, clearError: true));
    }

    try {
      // Start both reads together
      final eventsFuture = _service.fetchEvents();
      final registeredFuture = _service.fetchRegisteredEventIds();

      final events = await eventsFuture;
      final registered = await registeredFuture;
      if (emit.isDone) return;

      emit(
        state.copyWith(
          status: EventsStatus.loaded,
          events: events,
          registeredIds: registered,
          refreshing: false,
        ),
      );
    } on EventsFailure catch (e) {
      if (emit.isDone) return;
      // A failed refresh keeps showing the old list.
      emit(
        state.copyWith(
          status: state.events.isEmpty
              ? EventsStatus.failure
              : EventsStatus.loaded,
          refreshing: false,
          error: e.message,
        ),
      );
    }
  }

  Future<void> _onRegister(
    EventRegisterConfirmed event,
    Emitter<EventsState> emit,
  ) async {
    if (state.registeringId != null) return; // one at a time

    final matches = state.events.where((e) => e.id == event.eventId);
    if (matches.isEmpty) return;
    final item = matches.first;

    if (state.isRegistered(item.id)) return;

    // Registration may have closed while the screen was open.
    if (!item.isRegistrationOpen(DateTime.now())) {
      _showMessage(emit, 'Registration is closed for this event');
      return;
    }

    emit(state.copyWith(registeringId: item.id));

    try {
      await _service.register(item);
      if (emit.isDone) return;

      emit(
        state.copyWith(
          registeredIds: {...state.registeredIds, item.id},
          clearRegistering: true,
        ),
      );
      _showMessage(emit, 'You are registered for "${item.title}"');
    } on EventsFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(clearRegistering: true));
      _showMessage(emit, e.message);
    }
  }

  void _showMessage(Emitter<EventsState> emit, String message) {
    emit(state.copyWith(message: message));
    emit(state.copyWith(clearMessage: true));
  }
}
