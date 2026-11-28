part of 'community_chat_bloc.dart';

enum CommunityChatStatus { initial, loading, success, failure }

final class CommunityChatState extends Equatable {
  const CommunityChatState({
    this.status = CommunityChatStatus.initial,
    this.community,
    this.currentUser,
    this.messages = const [],
    this.messagesLoaded = false,
    this.reachedEnd = false,
    this.isLoadingMore = false,
    this.isSending = false,
    this.hasLeft = false,
    this.errorMessage,
    this.infoMessage,
  });

  final CommunityChatStatus status;
  final CommunityModel? community;
  final CommunityUser? currentUser;

  /// Newest first (the UI renders the list reversed).
  final List<CommunityMessage> messages;
  final bool messagesLoaded;
  /// The newest-N query returned fewer than N messages (no older ones exist).
  final bool reachedEnd;
  final bool isLoadingMore;
  final bool isSending;

  /// True after the user left the community (the screen closes itself).
  final bool hasLeft;

  /// One-shot error for the UI (cleared on the next emit).
  final String? errorMessage;
  final String? infoMessage;

  DateTime? get _clearedAt =>
      (community == null || currentUser == null)
          ? null
          : community!.clearedAtFor(currentUser!.id);

  /// Messages after the time this user cleared the chat.
  List<CommunityMessage> get visibleMessages {
    final cleared = _clearedAt;
    if (cleared == null) return messages;
    return messages.where((m) => m.createdAt.isAfter(cleared)).toList();
  }

  /// No older messages to load (or everything older was cleared).
  bool get hasReachedMax {
    if (reachedEnd) return true;
    final cleared = _clearedAt;
    return cleared != null && messages.any((m) => !m.createdAt.isAfter(cleared));
  }

  bool get isAdmin =>
      community != null &&
      currentUser != null &&
      community!.adminId == currentUser!.id;

  /// Admin always; participants only while the admin enabled messaging.
  bool get canSend =>
      community != null &&
      currentUser != null &&
      community!.canSend(currentUser!.id);

  /// Admin can delete any message; others only their own.
  bool canDelete(CommunityMessage message) {
    if (message.isDeleted || currentUser == null) return false;
    return isAdmin || (message.senderId == currentUser!.id && canSend);
  }

  bool isMine(CommunityMessage message) =>
      currentUser != null && message.senderId == currentUser!.id;

  CommunityChatState copyWith({
    CommunityChatStatus? status,
    CommunityModel? community,
    CommunityUser? currentUser,
    List<CommunityMessage>? messages,
    bool? messagesLoaded,
    bool? reachedEnd,
    bool? isLoadingMore,
    bool? isSending,
    bool? hasLeft,
    String? errorMessage,
    String? infoMessage,
  }) {
    return CommunityChatState(
      status: status ?? this.status,
      community: community ?? this.community,
      currentUser: currentUser ?? this.currentUser,
      messages: messages ?? this.messages,
      messagesLoaded: messagesLoaded ?? this.messagesLoaded,
      reachedEnd: reachedEnd ?? this.reachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      hasLeft: hasLeft ?? this.hasLeft,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        community,
        currentUser,
        messages,
        messagesLoaded,
        reachedEnd,
        isLoadingMore,
        isSending,
        hasLeft,
        errorMessage,
        infoMessage,
      ];
}