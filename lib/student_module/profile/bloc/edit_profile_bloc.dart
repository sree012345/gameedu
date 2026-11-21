import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/student_module/create_profile/models/user_profile.dart';
import 'package:game_edu/student_module/create_profile/validators/profile_validators.dart';

import '../services/profile_service.dart';
import '../validators/contact_validators.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

/// "Edit Profile": pre-fills from Firebase, validates ONE error at a time,
/// uploads the new photo (if any) and saves.
///
/// Email / mobile number: if the user already has one it is read-only,
/// if missing the user can add it (once).
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({required ProfileService service})
    : _service = service,
      super(const EditProfileState()) {
    on<EditProfileStarted>(_onStarted);
    on<EditPhotoSelected>(_onPhotoSelected);
    on<EditFullNameChanged>(
      (e, emit) =>
          emit(_typing(EditField.fullName).copyWith(fullName: e.value)),
    );
    on<EditEmailChanged>(
      (e, emit) => emit(_typing(EditField.email).copyWith(newEmail: e.value)),
    );
    on<EditPhoneChanged>(
      (e, emit) => emit(_typing(EditField.phone).copyWith(newPhone: e.value)),
    );
    on<EditGenderSelected>(
      (e, emit) => emit(_typing(EditField.gender).copyWith(gender: e.gender)),
    );
    on<EditCollegeChanged>(
      (e, emit) => emit(_typing(EditField.college).copyWith(college: e.value)),
    );
    on<EditDepartmentChanged>(
      (e, emit) =>
          emit(_typing(EditField.department).copyWith(department: e.value)),
    );
    on<EditYearSelected>(
      (e, emit) => emit(_typing(EditField.year).copyWith(yearOfStudy: e.year)),
    );
    on<EditSavePressed>(_onSave);
  }

  final ProfileService _service;

  Future<void> _onStarted(
    EditProfileStarted event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(status: EditProfileStatus.loading));

    try {
      final p = await _service.getProfile();
      if (emit.isDone) return;

      emit(
        state.copyWith(
          status: EditProfileStatus.ready,
          photoUrl: p.photoUrl,
          fullName: p.fullName,
          email: p.email,
          phone: p.phone,
          gender: p.gender,
          college: p.college,
          department: p.department,
          yearOfStudy: p.yearOfStudy,
        ),
      );
    } on ProfileServiceFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: EditProfileStatus.ready, serverError: e.message));
    }
  }

  void _onPhotoSelected(
    EditPhotoSelected event,
    Emitter<EditProfileState> emit,
  ) {
    final message = ProfileValidators.photo(event.photo);
    if (message != null) {
      _showFieldError(emit, EditFieldError(EditField.photo, message));
      return;
    }
    emit(_typing(EditField.photo).copyWith(photo: event.photo));
  }

  Future<void> _onSave(
    EditSavePressed event,
    Emitter<EditProfileState> emit,
  ) async {
    if (state.isSaving || state.isLoading) return;

    final error = _firstError();
    if (error != null) {
      _showFieldError(emit, error);
      return;
    }

    emit(
      state.copyWith(
        status: EditProfileStatus.saving,
        clearFieldError: true,
        clearServerError: true,
      ),
    );

    // Only a MISSING email / phone can be added.
    final addEmail = state.canAddEmail ? state.newEmail.trim().toLowerCase() : '';
    final addPhone = state.canAddPhone ? state.newPhone.trim() : '';

    try {
      String? photoUrl;
      final photo = state.photo;
      if (photo != null) {
        photoUrl = await _service.uploadPhoto(photo.bytes);
      }

      await _service.updateProfile(
        UserProfile(
          fullName: state.fullName.trim(),
          gender: state.gender,
          college: state.college.trim(),
          department: state.department.trim(),
          yearOfStudy: state.yearOfStudy,
        ),
        photoUrl: photoUrl,
        email: addEmail.isEmpty ? null : addEmail,
        phone: addPhone.isEmpty ? null : ContactValidators.toE164(addPhone),
      );
      if (emit.isDone) return;

      emit(state.copyWith(status: EditProfileStatus.saved));
    } on ProfileServiceFailure catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: EditProfileStatus.ready, serverError: e.message));
    }
  }

  // ───────────── validation ─────────────

  /// First invalid field, in screen order.
  EditFieldError? _firstError() {
    final checks = <(EditField, String?)>[
      (EditField.fullName, ProfileValidators.fullName(state.fullName)),
      if (state.canAddEmail)
        (EditField.email, ContactValidators.optionalEmail(state.newEmail)),
      if (state.canAddPhone)
        (EditField.phone, ContactValidators.optionalMobile(state.newPhone)),
      (EditField.gender, ProfileValidators.gender(state.gender)),
      (EditField.college, ProfileValidators.college(state.college)),
      (EditField.department, ProfileValidators.department(state.department)),
      (EditField.year, ProfileValidators.year(state.yearOfStudy)),
    ];

    for (final (field, message) in checks) {
      if (message != null) return EditFieldError(field, message);
    }
    return null;
  }

  void _showFieldError(Emitter<EditProfileState> emit, EditFieldError error) {
    emit(
      state.copyWith(
        clearServerError: true,
        errorField: error.field,
        errorMessage: error.message,
      ),
    );
  }

  /// While typing: remove this field's error and any server error.
  EditProfileState _typing(EditField field) => state.copyWith(
    clearFieldError: state.errorField == field,
    clearServerError: true,
  );
}
