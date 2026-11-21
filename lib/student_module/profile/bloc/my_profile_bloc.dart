import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/student_module/create_profile/models/user_profile.dart';

import '../services/profile_service.dart';

part 'my_profile_event.dart';
part 'my_profile_state.dart';

/// "My Profile" screen: loads the profile from Firebase.
class MyProfileBloc extends Bloc<MyProfileEvent, MyProfileState> {
  MyProfileBloc({required ProfileService service})
    : _service = service,
      super(const MyProfileState()) {
    on<MyProfileStarted>(
      (e, emit) => _load(emit, showLoader: true),
    );
    on<MyProfileRefreshed>(
      (e, emit) => _load(emit, showLoader: false),
    );
  }

  final ProfileService _service;

  Future<void> _load(
    Emitter<MyProfileState> emit, {
    required bool showLoader,
  }) async {
    if (showLoader) {
      emit(state.copyWith(status: MyProfileStatus.loading, clearError: true));
    }

    try {
      final profile = await _service.getProfile();
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: MyProfileStatus.loaded,
          profile: profile,
          clearError: true,
        ),
      );
    } on ProfileServiceFailure catch (e) {
      if (emit.isDone) return;
      // A failed refresh keeps showing the old data.
      emit(
        state.copyWith(
          status: state.profile == null
              ? MyProfileStatus.failure
              : MyProfileStatus.loaded,
          error: e.message,
        ),
      );
    }
  }
}
