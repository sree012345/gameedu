import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/community_exception.dart';
import '../../data/models/community_model.dart';
import '../../data/models/community_user.dart';
import '../../data/services/community_firebase_service.dart';

part 'community_list_event.dart';
part 'community_list_state.dart';

class CommunityListBloc extends Bloc<CommunityListEvent, CommunityListState> {
  CommunityListBloc({required CommunityFirebaseService service})
      : _service = service,
        super(const CommunityListState()) {
    on<CommunityListStarted>(_onStarted);
  }

  final CommunityFirebaseService _service;

  Future<void> _onStarted(
    CommunityListStarted event,
    Emitter<CommunityListState> emit,
  ) async {
    emit(state.copyWith(status: CommunityListStatus.loading));
    try {
      final user = await _service.loadCurrentUser();
      emit(state.copyWith(status: CommunityListStatus.loading, currentUser: user));

      await emit.forEach<List<CommunityModel>>(
        _service.watchCommunities(user),
        onData: (communities) => state.copyWith(
          status: CommunityListStatus.success,
          communities: communities,
        ),
        onError: (error, _) => state.copyWith(
          status: CommunityListStatus.failure,
          errorMessage: CommunityException.messageOf(error),
        ),
      );
    } catch (error) {
      emit(state.copyWith(
        status: CommunityListStatus.failure,
        errorMessage: CommunityException.messageOf(error),
      ));
    }
  }
}
