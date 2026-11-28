import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/community_exception.dart';
import '../../data/models/community_message.dart';
import '../../data/models/community_model.dart';
import '../../data/models/community_user.dart';
import '../../data/services/community_firebase_service.dart';

part 'community_details_event.dart';
part 'community_details_state.dart';

EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);

class CommunityDetailsBloc
    extends Bloc<CommunityDetailsEvent, CommunityDetailsState> {
  CommunityDetailsBloc({required CommunityFirebaseService service})
      : _service = service,
        super(const CommunityDetailsState()) {
    on<CommunityDetailsStarted>(_onStarted);
    on<CommunityDetailsCommunityChanged>(
      _onCommunityChanged,
      transformer: _sequential(),
    );
    on<CommunityDetailsMediaChanged>(
      (event, emit) => emit(state.copyWith(media: event.media)),
    );
    on<CommunityDetailsFailed>(
      (event, emit) => emit(state.copyWith(
        status: CommunityDetailsStatus.failure,
        errorMessage: event.message,
      )),
    );
    on<CommunityParticipantsAdded>(_onParticipantsAdded);
    on<CommunityParticipantRemoved>(_onParticipantRemoved);
    on<CommunityMessagingToggled>(_onMessagingToggled);
    on<CommunityEdited>(_onEdited);
  }

  final CommunityFirebaseService _service;
  final Map<String, CommunityUser> _userCache = {};

  String _communityId = '';
  StreamSubscription<CommunityModel?>? _communitySub;
  StreamSubscription<List<CommunityMessage>>? _mediaSub;

  Future<void> _onStarted(
    CommunityDetailsStarted event,
    Emitter<CommunityDetailsState> emit,
  ) async {
    _communityId = event.communityId;
    emit(state.copyWith(status: CommunityDetailsStatus.loading));
    try {
      final user = await _service.loadCurrentUser();
      emit(state.copyWith(
        status: CommunityDetailsStatus.loading,
        currentUser: user,
      ));

      await _communitySub?.cancel();
      await _mediaSub?.cancel();

      _communitySub = _service.watchCommunity(_communityId).listen(
            (community) => add(CommunityDetailsCommunityChanged(community)),
            onError: (Object e) =>
                add(CommunityDetailsFailed(CommunityException.messageOf(e))),
          );
      _mediaSub = _service.watchMedia(_communityId).listen(
            (media) => add(CommunityDetailsMediaChanged(media)),
            onError: (Object e) =>
                add(CommunityDetailsFailed(CommunityException.messageOf(e))),
          );
    } catch (error) {
      emit(state.copyWith(
        status: CommunityDetailsStatus.failure,
        errorMessage: CommunityException.messageOf(error),
      ));
    }
  }

  Future<void> _onCommunityChanged(
    CommunityDetailsCommunityChanged event,
    Emitter<CommunityDetailsState> emit,
  ) async {
    final community = event.community;
    if (community == null) {
      emit(state.copyWith(
        status: CommunityDetailsStatus.failure,
        errorMessage: 'This community is no longer available.',
      ));
      return;
    }

    try {
      final allIds = [community.adminId, ...community.participantIds];
      final missing = allIds.where((id) => !_userCache.containsKey(id)).toList();
      if (missing.isNotEmpty) {
        final users = await _service.getUsersByIds(missing);
        for (final u in users) {
          _userCache[u.id] = u;
        }
      }

      final members = allIds
          .map((id) =>
              _userCache[id] ?? CommunityUser(id: id, name: 'Unknown user'))
          .toList();

      emit(state.copyWith(
        status: CommunityDetailsStatus.success,
        community: community,
        members: members,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CommunityDetailsStatus.failure,
        errorMessage: CommunityException.messageOf(error),
      ));
    }
  }

  Future<void> _onParticipantsAdded(
    CommunityParticipantsAdded event,
    Emitter<CommunityDetailsState> emit,
  ) async {
    if (!state.isAdmin || event.userIds.isEmpty) return;
    await _runAction(
      emit,
      () => _service.addParticipants(_communityId, event.userIds),
      success: event.userIds.length == 1
          ? 'Participant added'
          : '${event.userIds.length} participants added',
    );
  }

  Future<void> _onParticipantRemoved(
    CommunityParticipantRemoved event,
    Emitter<CommunityDetailsState> emit,
  ) async {
    if (!state.isAdmin) return;
    await _runAction(
      emit,
      () => _service.removeParticipant(_communityId, event.userId),
      success: 'Participant removed',
    );
  }

  Future<void> _onMessagingToggled(
    CommunityMessagingToggled event,
    Emitter<CommunityDetailsState> emit,
  ) async {
    if (!state.isAdmin) return;
    await _runAction(
      emit,
      () => _service.setParticipantsCanMessage(_communityId, event.enabled),
      success: event.enabled
          ? 'Participants can now send messages'
          : 'Only admin can send messages',
    );
  }

  Future<void> _onEdited(
    CommunityEdited event,
    Emitter<CommunityDetailsState> emit,
  ) async {
    // Only the admin of this community can edit it.
    if (!state.isAdmin) {
      emit(state.copyWith(errorMessage: 'Only the admin can edit this community.'));
      return;
    }
    final name = event.name.trim();
    if (name.length < 2) {
      emit(state.copyWith(errorMessage: 'Please enter a community name.'));
      return;
    }
    await _runAction(
      emit,
      () => _service.updateCommunity(
        communityId: _communityId,
        name: name,
        description: event.description.trim(),
        currentImageUrl: state.community?.imageUrl,
        newImage: event.newImage,
        removeImage: event.removeImage,
      ),
      success: 'Community updated',
    );
  }

  Future<void> _runAction(
    Emitter<CommunityDetailsState> emit,
    Future<void> Function() action, {
    required String success,
  }) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await action();
      emit(state.copyWith(isUpdating: false, infoMessage: success));
    } catch (error) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: CommunityException.messageOf(error),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _communitySub?.cancel();
    await _mediaSub?.cancel();
    return super.close();
  }
}