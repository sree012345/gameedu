part of 'classes_bloc.dart';

sealed class ClassesEvent extends Equatable {
  const ClassesEvent();

  @override
  List<Object?> get props => [];
}

/// First load (shows the spinner).
final class ClassesStarted extends ClassesEvent {
  const ClassesStarted();
}

/// Pull to refresh (keeps the list on screen).
final class ClassesRefreshed extends ClassesEvent {
  const ClassesRefreshed();
}

/// "All Classes" / "My Classes" switch.
final class ClassesViewChanged extends ClassesEvent {
  const ClassesViewChanged(this.view);
  final ClassesView view;

  @override
  List<Object?> get props => [view];
}

final class ClassesSearchChanged extends ClassesEvent {
  const ClassesSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// null = "All Topics".
final class ClassesTopicSelected extends ClassesEvent {
  const ClassesTopicSelected(this.topic);
  final String? topic;

  @override
  List<Object?> get props => [topic];
}
