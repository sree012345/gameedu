part of 'community_details_bloc.dart';

sealed class CommunityDetailsEvent extends Equatable {
  const CommunityDetailsEvent();

  @override
  List<Object?> get props => [];
}

final class CommunityDetailsStarted extends CommunityDetailsEvent {
  const CommunityDetailsStarted(this.communityId);

  final String communityId;

  @override
  List<Object?> get props => [communityId];
}

/// Internal: emitted by the Firestore community stream.
final class CommunityDetailsCommunityChanged extends CommunityDetailsEvent {
  const CommunityDetailsCommunityChanged(this.community);

  final CommunityModel? community;

  @override
  List<Object?> get props => [community];
}

/// Internal: emitted by the Firestore media stream.
final class CommunityDetailsMediaChanged extends CommunityDetailsEvent {
  const CommunityDetailsMediaChanged(this.media);

  final List<CommunityMessage> media;

  @override
  List<Object?> get props => [media];
}

/// Internal: a stream reported an error.
final class CommunityDetailsFailed extends CommunityDetailsEvent {
  const CommunityDetailsFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CommunityParticipantsAdded extends CommunityDetailsEvent {
  const CommunityParticipantsAdded(this.userIds);

  final List<String> userIds;

  @override
  List<Object?> get props => [userIds];
}

final class CommunityParticipantRemoved extends CommunityDetailsEvent {
  const CommunityParticipantRemoved(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class CommunityMessagingToggled extends CommunityDetailsEvent {
  const CommunityMessagingToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Admin edits the community name, description and/or picture.
final class CommunityEdited extends CommunityDetailsEvent {
  const CommunityEdited({
    required this.name,
    required this.description,
    this.newImage,
    this.removeImage = false,
  });

  final String name;
  final String description;
  final File? newImage;
  final bool removeImage;

  @override
  List<Object?> get props => [name, description, newImage?.path, removeImage];
}