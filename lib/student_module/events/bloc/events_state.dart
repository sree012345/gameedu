part of 'events_bloc.dart';

enum EventsStatus { loading, loaded, failure }

final class EventsState extends Equatable {
  const EventsState({
    this.status = EventsStatus.loading,
    this.events = const [],
    this.registeredIds = const {},
    this.registeringId,
    this.refreshing = false,
    this.error,
    this.message,
  });

  final EventsStatus status;
  final List<EventItem> events;

  /// Events this user is registered for.
  final Set<String> registeredIds;

  /// Event whose registration is being saved (button spinner).
  final String? registeringId;
  final bool refreshing;
  final String? error;

  /// One-shot snackbar text.
  final String? message;

  bool isRegistered(String eventId) => registeredIds.contains(eventId);

  EventsState copyWith({
    EventsStatus? status,
    List<EventItem>? events,
    Set<String>? registeredIds,
    String? registeringId,
    bool? refreshing,
    String? error,
    String? message,
    bool clearRegistering = false,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return EventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      registeredIds: registeredIds ?? this.registeredIds,
      registeringId: clearRegistering
          ? null
          : (registeringId ?? this.registeringId),
      refreshing: refreshing ?? this.refreshing,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    status,
    events,
    registeredIds,
    registeringId,
    refreshing,
    error,
    message,
  ];
}
