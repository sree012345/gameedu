import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/profile_constants.dart';
import '../models/user_profile.dart';
import '../services/create_profile_service.dart';
import '../validators/profile_validators.dart';

part 'create_profile_event.dart';
part 'create_profile_state.dart';

/// 3-step Create Profile (Basic -> College -> Interests).
///
/// * Name + college are pre-filled from the user document.
/// * Validation shows ONE error at a time (first invalid field of the step).
/// * Finish saves everything and sets `onboardingCompleted: true`.
class CreateProfileBloc extends Bloc<CreateProfileEvent, CreateProfileState> {
  CreateProfileBloc({required CreateProfileService service})
    : _service = service,
      super(const CreateProfileState()) {
    on<CreateProfileStarted>(_onStarted);

    on<ProfilePhotoSelected>(_onPhotoSelected);
    on<ProfilePhotoRemoved>(
      (e, emit) => emit(
        _typing(ProfileField.photo).copyWith(clearPhoto: true, photoUrl: ''),
      ),
    );
    on<ProfileFullNameChanged>(
      (e, emit) =>
          emit(_typing(ProfileField.fullName).copyWith(fullName: e.value)),
    );
    on<ProfileGenderSelected>(
      (e, emit) => emit(_typing(ProfileField.gender).copyWith(gender: e.gender)),
    );

    on<ProfileCollegeChanged>(
      (e, emit) =>
          emit(_typing(ProfileField.college).copyWith(college: e.value)),
    );
    on<ProfileDepartmentChanged>(
      (e, emit) =>
          emit(_typing(ProfileField.department).copyWith(department: e.value)),
    );
    on<ProfileYearSelected>(
      (e, emit) =>
          emit(_typing(ProfileField.year).copyWith(yearOfStudy: e.year)),
    );
    on<ProfileStudentIdChanged>(
      (e, emit) =>
          emit(_typing(ProfileField.studentId).copyWith(studentId: e.value)),
    );

    on<ProfileInterestToggled>(_onInterestToggled);
    on<ProfileSkillLevelSelected>(
      (e, emit) => emit(
        state.copyWith(skillLevel: e.level, clearServerError: true),
      ),
    );

    on<ProfileNextPressed>(_onNext);
    on<ProfileBackPressed>(_onBack);
    on<ProfileSkipPressed>(_onSkip);
  }

  final CreateProfileService _service;

  // ───────────────────────── load / pre-fill ─────────────────────────

  Future<void> _onStarted(
    CreateProfileStarted event,
    Emitter<CreateProfileState> emit,
  ) async {
    emit(state.copyWith(status: CreateProfileStatus.loading));

    try {
      final p = await _service.getProfile();
      if (emit.isDone) return;

      emit(
        state.copyWith(
          status: CreateProfileStatus.ready,
          fullName: p.fullName,
          photoUrl: p.photoUrl,
          gender: p.gender,
          college: p.college,
          department: p.department,
          yearOfStudy: p.yearOfStudy,
          studentId: p.studentId,
          interests: p.interests,
          skillLevel: p.skillLevel,
        ),
      );
    } on ProfileFailure catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(status: CreateProfileStatus.ready, serverError: e.message),
      );
    }
  }

  // ───────────────────────── field handlers ─────────────────────────

  void _onPhotoSelected(
    ProfilePhotoSelected event,
    Emitter<CreateProfileState> emit,
  ) {
    final message = ProfileValidators.photo(event.photo);
    if (message != null) {
      _showFieldError(emit, ProfileFieldError(ProfileField.photo, message));
      return;
    }
    emit(_typing(ProfileField.photo).copyWith(photo: event.photo));
  }

  void _onInterestToggled(
    ProfileInterestToggled event,
    Emitter<CreateProfileState> emit,
  ) {
    final list = List<String>.of(state.interests);
    if (!list.remove(event.id)) list.add(event.id);
    emit(_typing(ProfileField.interests).copyWith(interests: list));
  }

  // ───────────────────────── navigation ─────────────────────────

  Future<void> _onNext(
    ProfileNextPressed event,
    Emitter<CreateProfileState> emit,
  ) async {
    if (state.isSaving || state.isLoading) return;

    final error = _firstError(state.step);
    if (error != null) {
      _showFieldError(emit, error);
      return;
    }

    if (!state.isLastStep) {
      emit(
        state.copyWith(
          step: state.step + 1,
          clearFieldError: true,
          clearServerError: true,
        ),
      );
      return;
    }

    await _finish(emit);
  }

  void _onBack(ProfileBackPressed event, Emitter<CreateProfileState> emit) {
    if (state.isSaving || state.step == 0) return;
    emit(
      state.copyWith(
        step: state.step - 1,
        clearFieldError: true,
        clearServerError: true,
      ),
    );
  }

  Future<void> _onSkip(
    ProfileSkipPressed event,
    Emitter<CreateProfileState> emit,
  ) async {
    if (state.isSaving || state.isLoading) return;

    emit(
      state.copyWith(
        status: CreateProfileStatus.saving,
        clearFieldError: true,
        clearServerError: true,
      ),
    );
    try {
      await _service.skip();
      if (emit.isDone) return;
      emit(state.copyWith(status: CreateProfileStatus.completed));
    } on ProfileFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: CreateProfileStatus.ready, serverError: e.message));
    }
  }

  Future<void> _finish(Emitter<CreateProfileState> emit) async {
    emit(
      state.copyWith(
        status: CreateProfileStatus.saving,
        clearFieldError: true,
        clearServerError: true,
      ),
    );

    try {
      String? photoUrl;
      final photo = state.photo;
      if (photo != null) {
        photoUrl = await _service.uploadPhoto(
          bytes: photo.bytes,
          fileName: photo.fileName,
        );
      }

      await _service.saveProfile(
        UserProfile(
          fullName: state.fullName.trim(),
          gender: state.gender,
          college: state.college.trim(),
          department: state.department.trim(),
          yearOfStudy: state.yearOfStudy,
          studentId: state.studentId.trim(),
          interests: state.interests,
          skillLevel: state.skillLevel,
        ),
        photoUrl: photoUrl,
      );
      if (emit.isDone) return;

      emit(state.copyWith(status: CreateProfileStatus.completed));
    } on ProfileFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: CreateProfileStatus.ready, serverError: e.message));
    }
  }

  // ───────────────────────── validation helpers ─────────────────────────

  /// First invalid field of the given step, in screen order.
  ProfileFieldError? _firstError(int step) {
    switch (step) {
      case 0:
        return _first(<(ProfileField, String?)>[
          (ProfileField.fullName, ProfileValidators.fullName(state.fullName)),
          (ProfileField.gender, ProfileValidators.gender(state.gender)),
        ]);
      case 1:
        return _first(<(ProfileField, String?)>[
          (ProfileField.college, ProfileValidators.college(state.college)),
          (ProfileField.department, ProfileValidators.department(state.department)),
          (ProfileField.year, ProfileValidators.year(state.yearOfStudy)),
          (ProfileField.studentId, ProfileValidators.studentId(state.studentId)),
        ]);
      default:
        return _first(<(ProfileField, String?)>[
          (ProfileField.interests, ProfileValidators.interests(state.interests)),
        ]);
    }
  }

  ProfileFieldError? _first(List<(ProfileField, String?)> checks) {
    for (final (field, message) in checks) {
      if (message != null) return ProfileFieldError(field, message);
    }
    return null;
  }

  void _showFieldError(
    Emitter<CreateProfileState> emit,
    ProfileFieldError error,
  ) {
    emit(
      state.copyWith(
        clearServerError: true,
        errorField: error.field,
        errorMessage: error.message,
      ),
    );
  }

  /// While typing: remove this field's error and any server error.
  CreateProfileState _typing(ProfileField field) => state.copyWith(
    clearFieldError: state.errorField == field,
    clearServerError: true,
  );
}
