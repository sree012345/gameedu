part of 'create_community_bloc.dart';

sealed class CreateCommunityEvent extends Equatable {
  const CreateCommunityEvent();

  @override
  List<Object?> get props => [];
}

final class CreateCommunityNameChanged extends CreateCommunityEvent {
  const CreateCommunityNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class CreateCommunityDescriptionChanged extends CreateCommunityEvent {
  const CreateCommunityDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

final class CreateCommunityImageChanged extends CreateCommunityEvent {
  const CreateCommunityImageChanged(this.file);

  /// `null` removes the selected image.
  final File? file;

  @override
  List<Object?> get props => [file?.path];
}

final class CreateCommunityParticipantsChanged extends CreateCommunityEvent {
  const CreateCommunityParticipantsChanged(this.participantIds);

  final List<String> participantIds;

  @override
  List<Object?> get props => [participantIds];
}

final class CreateCommunitySubmitted extends CreateCommunityEvent {
  const CreateCommunitySubmitted();
}