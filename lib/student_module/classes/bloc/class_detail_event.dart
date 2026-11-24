part of 'class_detail_bloc.dart';

sealed class ClassDetailEvent extends Equatable {
  const ClassDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load the classes (lessons) and the user's progress.
final class ClassDetailStarted extends ClassDetailEvent {
  const ClassDetailStarted();
}

/// Re-read the user's progress (after coming back from a class page).
final class ClassDetailRefreshed extends ClassDetailEvent {
  const ClassDetailRefreshed();
}