part of 'create_profile_bloc.dart';

enum CreateProfileStatus {
  loading,
  ready,
  saving,

  /// One-shot trigger: open the dashboard.
  completed,
}

/// Fields that can show a validation error (only one at a time).
enum ProfileField {
  photo,
  fullName,
  gender,
  college,
  department,
  year,
  studentId,
  interests,
}

final class ProfileFieldError {
  const ProfileFieldError(this.field, this.message);

  final ProfileField field;
  final String message;
}

final class CreateProfileState extends Equatable {
  const CreateProfileState({
    this.status = CreateProfileStatus.loading,
    this.step = 0,
    // step 1
    this.photo,
    this.photoUrl = '',
    this.fullName = '',
    this.gender,
    // step 2
    this.college = '',
    this.department = '',
    this.yearOfStudy,
    this.studentId = '',
    // step 3
    this.interests = const [],
    this.skillLevel = SkillLevel.beginner,
    // errors
    this.errorField,
    this.errorMessage,
    this.serverError,
  });

  static const List<String> stepTitles = [
    'Basic Details',
    'College Details',
    'Interests',
  ];

  final CreateProfileStatus status;
  final int step;

  final PickedPhoto? photo;
  final String photoUrl;
  final String fullName;
  final Gender? gender;

  final String college;
  final String department;
  final int? yearOfStudy;
  final String studentId;

  final List<String> interests;
  final SkillLevel skillLevel;

  final ProfileField? errorField;
  final String? errorMessage;

  /// Firebase / network error, shown in red under the buttons.
  final String? serverError;

  bool get isSaving => status == CreateProfileStatus.saving;
  bool get isLoading => status == CreateProfileStatus.loading;
  bool get isLastStep => step == ProfileConstants.stepCount - 1;

  String? _errorFor(ProfileField field) =>
      errorField == field ? errorMessage : null;

  String? get photoError => _errorFor(ProfileField.photo);
  String? get fullNameError => _errorFor(ProfileField.fullName);
  String? get genderError => _errorFor(ProfileField.gender);
  String? get collegeError => _errorFor(ProfileField.college);
  String? get departmentError => _errorFor(ProfileField.department);
  String? get yearError => _errorFor(ProfileField.year);
  String? get studentIdError => _errorFor(ProfileField.studentId);
  String? get interestsError => _errorFor(ProfileField.interests);

  CreateProfileState copyWith({
    CreateProfileStatus? status,
    int? step,
    PickedPhoto? photo,
    String? photoUrl,
    String? fullName,
    Gender? gender,
    String? college,
    String? department,
    int? yearOfStudy,
    String? studentId,
    List<String>? interests,
    SkillLevel? skillLevel,
    ProfileField? errorField,
    String? errorMessage,
    String? serverError,
    bool clearPhoto = false,
    bool clearFieldError = false,
    bool clearServerError = false,
  }) {
    return CreateProfileState(
      status: status ?? this.status,
      step: step ?? this.step,
      photo: clearPhoto ? null : (photo ?? this.photo),
      photoUrl: photoUrl ?? this.photoUrl,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      college: college ?? this.college,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      studentId: studentId ?? this.studentId,
      interests: interests ?? this.interests,
      skillLevel: skillLevel ?? this.skillLevel,
      errorField: clearFieldError ? null : (errorField ?? this.errorField),
      errorMessage: clearFieldError ? null : (errorMessage ?? this.errorMessage),
      serverError: clearServerError ? null : (serverError ?? this.serverError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    step,
    photo,
    photoUrl,
    fullName,
    gender,
    college,
    department,
    yearOfStudy,
    studentId,
    interests,
    skillLevel,
    errorField,
    errorMessage,
    serverError,
  ];
}
