part of 'create_profile_bloc.dart';

sealed class CreateProfileEvent extends Equatable {
  const CreateProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load name / college (and anything saved before) to pre-fill the form.
final class CreateProfileStarted extends CreateProfileEvent {
  const CreateProfileStarted();
}

// ───────── Step 1 ─────────
final class ProfilePhotoSelected extends CreateProfileEvent {
  const ProfilePhotoSelected(this.photo);
  final PickedPhoto photo;

  @override
  List<Object?> get props => [photo];
}

final class ProfilePhotoRemoved extends CreateProfileEvent {
  const ProfilePhotoRemoved();
}

final class ProfileFullNameChanged extends CreateProfileEvent {
  const ProfileFullNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProfileGenderSelected extends CreateProfileEvent {
  const ProfileGenderSelected(this.gender);
  final Gender gender;

  @override
  List<Object?> get props => [gender];
}

// ───────── Step 2 ─────────
final class ProfileCollegeChanged extends CreateProfileEvent {
  const ProfileCollegeChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProfileDepartmentChanged extends CreateProfileEvent {
  const ProfileDepartmentChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProfileYearSelected extends CreateProfileEvent {
  const ProfileYearSelected(this.year);
  final int year;

  @override
  List<Object?> get props => [year];
}

final class ProfileStudentIdChanged extends CreateProfileEvent {
  const ProfileStudentIdChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

// ───────── Step 3 ─────────
final class ProfileInterestToggled extends CreateProfileEvent {
  const ProfileInterestToggled(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

final class ProfileSkillLevelSelected extends CreateProfileEvent {
  const ProfileSkillLevelSelected(this.level);
  final SkillLevel level;

  @override
  List<Object?> get props => [level];
}

// ───────── Navigation ─────────
/// "Continue" / "Finish Setup".
final class ProfileNextPressed extends CreateProfileEvent {
  const ProfileNextPressed();
}

final class ProfileBackPressed extends CreateProfileEvent {
  const ProfileBackPressed();
}

final class ProfileSkipPressed extends CreateProfileEvent {
  const ProfileSkipPressed();
}
