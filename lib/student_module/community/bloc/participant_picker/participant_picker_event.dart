part of 'participant_picker_bloc.dart';

sealed class ParticipantPickerEvent extends Equatable {
  const ParticipantPickerEvent();

  @override
  List<Object?> get props => [];
}

final class ParticipantPickerStarted extends ParticipantPickerEvent {
  const ParticipantPickerStarted({
    this.excludeIds = const {},
    this.initialSelected = const {},
  });

  /// Users that must not be offered (e.g. already in the community).
  final Set<String> excludeIds;
  final Set<String> initialSelected;

  @override
  List<Object?> get props => [excludeIds, initialSelected];
}

final class ParticipantPickerQueryChanged extends ParticipantPickerEvent {
  const ParticipantPickerQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ParticipantPickerToggled extends ParticipantPickerEvent {
  const ParticipantPickerToggled(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
