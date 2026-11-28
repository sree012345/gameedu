import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../community_config.dart';
import '../../data/community_exception.dart';
import '../../data/models/community_message.dart';
import '../../data/models/community_model.dart';
import '../../data/models/community_user.dart';
import '../../data/services/community_firebase_service.dart';
import '../../notification/community_notification_handler.dart';

part 'community_chat_event.dart';
part 'community_chat_state.dart';

EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);

class CommunityChatBloc extends Bloc<CommunityChatEvent, CommunityChatState> {
  CommunityChatBloc({required CommunityFirebaseService service})
      : _service = service,
        super(const CommunityChatState()) {
    on<CommunityChatStarted>(_onStarted);
    on<CommunityChatCommunityChanged>(
      _onCommunityChanged,
      transformer: _sequential(),
    );
    on<CommunityChatMessagesChanged>(_onMessagesChanged);
    on<CommunityChatFailed>(
      (event, emit) => emit(state.copyWith(
        status: state.community == null
            ? CommunityChatStatus.failure
            : state.status,
        errorMessage: event.message,
      )),
    );
    on<CommunityChatLoadMore>(_onLoadMore);
    on<CommunityChatTextSent>(_onTextSent, transformer: _sequential());
    on<CommunityChatMediaSent>(_onMediaSent, transformer: _sequential());
    on<CommunityChatMessageDeleted>(_onMessageDeleted);
    on<CommunityChatCleared>(_onCleared);
    on<CommunityChatLeft>(_onLeft);
  }

  final CommunityFirebaseService _service;

  String _communityId = '';
  int _limit = CommunityConfig.pageSize;
  StreamSubscription<CommunityModel?>? _communitySub;
  StreamSubscription<List<CommunityMessage>>? _messagesSub;

  Future<void> _onStarted(
    CommunityChatStarted event,
    Emitter<CommunityChatState> emit,
  ) async {
    _communityId = event.communityId;
    CommunityNotificationHandler.activeCommunityId = _communityId;

    emit(state.copyWith(status: CommunityChatStatus.loading));
    try {
      final user = await _service.loadCurrentUser();
      emit(state.copyWith(status: CommunityChatStatus.loading, currentUser: user));

      await _communitySub?.cancel();
      _communitySub = _service.watchCommunity(_communityId).listen(
            (community) => add(CommunityChatCommunityChanged(community)),
            onError: (Object e) =>
                add(CommunityChatFailed(CommunityException.messageOf(e))),
          );
      await _subscribeMessages();
    } catch (error) {
      emit(state.copyWith(
        status: CommunityChatStatus.failure,
        errorMessage: CommunityException.messageOf(error),
      ));
    }
  }

  Future<void> _subscribeMessages() async {
    await _messagesSub?.cancel();
    _messagesSub = _service.watchMessages(_communityId, limit: _limit).listen(
          (messages) => add(CommunityChatMessagesChanged(messages)),
          onError: (Object e) =>
              add(CommunityChatFailed(CommunityException.messageOf(e))),
        );
  }

  Future<void> _onCommunityChanged(
    CommunityChatCommunityChanged event,
    Emitter<CommunityChatState> emit,
  ) async {
    final community = event.community;
    final user = state.currentUser;

    if (community == null || (user != null && !community.isMember(user.id))) {
      emit(state.copyWith(
        status: CommunityChatStatus.failure,
        errorMessage: 'You no longer have access to this community.',
      ));
      return;
    }

    emit(state.copyWith(status: CommunityChatStatus.success, community: community));

    // Clear the unread badge while the chat is open.
    if (user != null && community.unreadFor(user.id) > 0) {
      try {
        await _service.markRead(_communityId, user.id);
      } catch (_) {
        // Not critical – the counter is cleared on the next open.
      }
    }
  }

  void _onMessagesChanged(
    CommunityChatMessagesChanged event,
    Emitter<CommunityChatState> emit,
  ) {
    emit(state.copyWith(
      messages: event.messages,
      messagesLoaded: true,
      isLoadingMore: false,
      reachedEnd: event.messages.length < _limit,
    ));
  }

  Future<void> _onLoadMore(
    CommunityChatLoadMore event,
    Emitter<CommunityChatState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || !state.messagesLoaded) return;
    _limit += CommunityConfig.pageSize;
    emit(state.copyWith(isLoadingMore: true));
    await _subscribeMessages();
  }

  Future<void> _onTextSent(
    CommunityChatTextSent event,
    Emitter<CommunityChatState> emit,
  ) async {
    final text = event.text.trim();
    final user = state.currentUser;
    if (text.isEmpty || user == null) return;

    if (!state.canSend) {
      emit(state.copyWith(errorMessage: 'You are not allowed to send messages here.'));
      return;
    }
    try {
      await _service.sendMessage(
        communityId: _communityId,
        sender: user,
        type: CommunityMessageType.text,
        text: text,
        recipientIds: _recipients(),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: CommunityException.messageOf(error)));
    }
  }

  Future<void> _onMediaSent(
    CommunityChatMediaSent event,
    Emitter<CommunityChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;

    if (!state.canSend) {
      emit(state.copyWith(errorMessage: 'You are not allowed to send messages here.'));
      return;
    }

    emit(state.copyWith(isSending: true));
    try {
      await _service.sendMessage(
        communityId: _communityId,
        sender: user,
        type: event.type,
        file: event.file,
        recipientIds: _recipients(),
      );
      emit(state.copyWith(isSending: false));
    } catch (error) {
      emit(state.copyWith(
        isSending: false,
        errorMessage: CommunityException.messageOf(error),
      ));
    }
  }

  Future<void> _onCleared(
    CommunityChatCleared event,
    Emitter<CommunityChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;
    try {
      await _service.clearChat(_communityId, user.id);
      emit(state.copyWith(infoMessage: 'Chat cleared'));
    } catch (error) {
      emit(state.copyWith(errorMessage: CommunityException.messageOf(error)));
    }
  }

  Future<void> _onLeft(
    CommunityChatLeft event,
    Emitter<CommunityChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;
    if (state.isAdmin) {
      emit(state.copyWith(errorMessage: 'The admin cannot leave the community.'));
      return;
    }
    try {
      // Stop listening first: after leaving, the user may no longer read the
      // community, so the streams would report a permission error.
      await _communitySub?.cancel();
      await _messagesSub?.cancel();
      await _service.leaveCommunity(_communityId, user);
      emit(state.copyWith(hasLeft: true, infoMessage: 'You left the community'));
    } catch (error) {
      emit(state.copyWith(errorMessage: CommunityException.messageOf(error)));
      // Leaving failed: listen again so the chat keeps working.
      _communitySub = _service.watchCommunity(_communityId).listen(
            (community) => add(CommunityChatCommunityChanged(community)),
          );
      await _subscribeMessages();
    }
  }

  /// Admin + participants (the service removes the sender).
  List<String> _recipients() {
    final community = state.community;
    if (community == null) return const [];
    return [community.adminId, ...community.participantIds];
  }

  Future<void> _onMessageDeleted(
    CommunityChatMessageDeleted event,
    Emitter<CommunityChatState> emit,
  ) async {
    if (!state.canDelete(event.message)) {
      emit(state.copyWith(errorMessage: 'You cannot delete this message.'));
      return;
    }
    try {
      await _service.deleteMessage(_communityId, event.message);
    } catch (error) {
      emit(state.copyWith(errorMessage: CommunityException.messageOf(error)));
    }
  }

  @override
  Future<void> close() async {
    if (CommunityNotificationHandler.activeCommunityId == _communityId) {
      CommunityNotificationHandler.activeCommunityId = null;
    }
    await _communitySub?.cancel();
    await _messagesSub?.cancel();
    return super.close();
  }
}