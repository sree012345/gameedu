part of 'community_chat_bloc.dart';

sealed class CommunityChatEvent extends Equatable {
  const CommunityChatEvent();

  @override
  List<Object?> get props => [];
}

final class CommunityChatStarted extends CommunityChatEvent {
  const CommunityChatStarted(this.communityId);

  final String communityId;

  @override
  List<Object?> get props => [communityId];
}

/// Internal: community document changed.
final class CommunityChatCommunityChanged extends CommunityChatEvent {
  const CommunityChatCommunityChanged(this.community);

  final CommunityModel? community;

  @override
  List<Object?> get props => [community];
}

/// Internal: message list changed.
final class CommunityChatMessagesChanged extends CommunityChatEvent {
  const CommunityChatMessagesChanged(this.messages);

  final List<CommunityMessage> messages;

  @override
  List<Object?> get props => [messages];
}

/// Internal: a stream reported an error.
final class CommunityChatFailed extends CommunityChatEvent {
  const CommunityChatFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Load older messages (call when the user scrolls to the top).
final class CommunityChatLoadMore extends CommunityChatEvent {
  const CommunityChatLoadMore();
}

final class CommunityChatTextSent extends CommunityChatEvent {
  const CommunityChatTextSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class CommunityChatMediaSent extends CommunityChatEvent {
  const CommunityChatMediaSent({required this.type, required this.file});

  final CommunityMessageType type;
  final File file;

  @override
  List<Object?> get props => [type, file.path];
}

/// Dispatch only after the user confirmed in the delete dialog.
final class CommunityChatMessageDeleted extends CommunityChatEvent {
  const CommunityChatMessageDeleted(this.message);

  final CommunityMessage message;

  @override
  List<Object?> get props => [message];
}

/// Clear the chat for the current user only (after the confirm dialog).
final class CommunityChatCleared extends CommunityChatEvent {
  const CommunityChatCleared();
}

/// Current participant leaves the community (after the confirm dialog).
final class CommunityChatLeft extends CommunityChatEvent {
  const CommunityChatLeft();
}