part of 'my_profile_bloc.dart';

sealed class MyProfileEvent extends Equatable {
  const MyProfileEvent();

  @override
  List<Object?> get props => [];
}

/// First load (shows the spinner).
final class MyProfileStarted extends MyProfileEvent {
  const MyProfileStarted();
}

/// Reload after editing (keeps the old data on screen).
final class MyProfileRefreshed extends MyProfileEvent {
  const MyProfileRefreshed();
}
