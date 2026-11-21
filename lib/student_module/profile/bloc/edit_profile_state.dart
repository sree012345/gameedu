part of 'edit_profile_bloc.dart';

enum EditProfileStatus {
  loading,
  ready,
  saving,

  /// One-shot trigger: close the screen and tell My Profile to refresh.
  saved,
}

/// Fields that can show a validation error (only one at a time).
enum EditField { photo, fullName, email, phone, gender, college, department, year }

final class EditFieldError {
  const EditFieldError(this.field, this.message);

  final EditField field;
  final String message;
}

final class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.loading,
    this.photo,
    this.photoUrl = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.newEmail = '',
    this.newPhone = '',
    this.gender,
    this.college = '',
    this.department = '',
    this.yearOfStudy,
    this.errorField,
    this.errorMessage,
    this.serverError,
  });

  final EditProfileStatus status;

  final PickedPhoto? photo;
  final String photoUrl;
  final String fullName;

  /// Saved values. When not empty they are shown read-only.
  final String email;
  final String phone;

  /// What the user typed when email / phone was missing.
  final String newEmail;
  final String newPhone;

  final Gender? gender;
  final String college;
  final String department;
  final int? yearOfStudy;

  final EditField? errorField;
  final String? errorMessage;

  /// Firebase / network error, shown in red above "Save Changes".
  final String? serverError;

  bool get isLoading => status == EditProfileStatus.loading;
  bool get isSaving => status == EditProfileStatus.saving;

  /// Email / phone can only be ADDED when the user has none.
  bool get canAddEmail => email.trim().isEmpty;
  bool get canAddPhone => phone.trim().isEmpty;

  String? _errorFor(EditField f) => errorField == f ? errorMessage : null;

  String? get photoError => _errorFor(EditField.photo);
  String? get fullNameError => _errorFor(EditField.fullName);
  String? get emailError => _errorFor(EditField.email);
  String? get phoneError => _errorFor(EditField.phone);
  String? get genderError => _errorFor(EditField.gender);
  String? get collegeError => _errorFor(EditField.college);
  String? get departmentError => _errorFor(EditField.department);
  String? get yearError => _errorFor(EditField.year);

  EditProfileState copyWith({
    EditProfileStatus? status,
    PickedPhoto? photo,
    String? photoUrl,
    String? fullName,
    String? email,
    String? phone,
    String? newEmail,
    String? newPhone,
    Gender? gender,
    String? college,
    String? department,
    int? yearOfStudy,
    EditField? errorField,
    String? errorMessage,
    String? serverError,
    bool clearFieldError = false,
    bool clearServerError = false,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      photo: photo ?? this.photo,
      photoUrl: photoUrl ?? this.photoUrl,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      newEmail: newEmail ?? this.newEmail,
      newPhone: newPhone ?? this.newPhone,
      gender: gender ?? this.gender,
      college: college ?? this.college,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      errorField: clearFieldError ? null : (errorField ?? this.errorField),
      errorMessage: clearFieldError ? null : (errorMessage ?? this.errorMessage),
      serverError: clearServerError ? null : (serverError ?? this.serverError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    photo,
    photoUrl,
    fullName,
    email,
    phone,
    newEmail,
    newPhone,
    gender,
    college,
    department,
    yearOfStudy,
    errorField,
    errorMessage,
    serverError,
  ];
}
