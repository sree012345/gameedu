part of 'edit_profile_bloc.dart';

sealed class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load the current data to pre-fill the form.
final class EditProfileStarted extends EditProfileEvent {
  const EditProfileStarted();
}

final class EditPhotoSelected extends EditProfileEvent {
  const EditPhotoSelected(this.photo);
  final PickedPhoto photo;

  @override
  List<Object?> get props => [photo];
}

final class EditFullNameChanged extends EditProfileEvent {
  const EditFullNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

/// Only used when the user has no email yet.
final class EditEmailChanged extends EditProfileEvent {
  const EditEmailChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

/// Only used when the user has no mobile number yet.
final class EditPhoneChanged extends EditProfileEvent {
  const EditPhoneChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class EditGenderSelected extends EditProfileEvent {
  const EditGenderSelected(this.gender);
  final Gender gender;

  @override
  List<Object?> get props => [gender];
}

final class EditCollegeChanged extends EditProfileEvent {
  const EditCollegeChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class EditDepartmentChanged extends EditProfileEvent {
  const EditDepartmentChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class EditYearSelected extends EditProfileEvent {
  const EditYearSelected(this.year);
  final int year;

  @override
  List<Object?> get props => [year];
}

/// "Save Changes".
final class EditSavePressed extends EditProfileEvent {
  const EditSavePressed();
}
