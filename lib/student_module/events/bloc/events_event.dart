part of 'events_bloc.dart';

sealed class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

/// First load (shows the spinner).
final class EventsStarted extends EventsEvent {
  const EventsStarted();
}

/// Pull to refresh.
final class EventsRefreshed extends EventsEvent {
  const EventsRefreshed();
}

/// The user pressed "Register" in the confirm popup.
final class EventRegisterConfirmed extends EventsEvent {
  const EventRegisterConfirmed(this.eventId);
  final String eventId;

  @override
  List<Object?> get props => [eventId];
}
