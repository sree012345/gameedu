import '../constants/profile_constants.dart';
import '../models/user_profile.dart';

/// Each validator returns null when valid, otherwise the message to show.
class ProfileValidators {
  ProfileValidators._();

  static final RegExp _nameRegex = RegExp(
    r"^[\p{L}][\p{L} .'\-]*$",
    unicode: true,
  );
  static final RegExp _textRegex = RegExp(
    r"^[\p{L}\p{N}][\p{L}\p{N} .,&'()\-/]*$",
    unicode: true,
  );
  static final RegExp _studentIdRegex = RegExp(r'^[A-Za-z0-9\-/]+$');

  static String? fullName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your full name';
    if (v.length < ProfileConstants.nameMinLength) {
      return 'Name must be at least ${ProfileConstants.nameMinLength} characters';
    }
    if (v.length > ProfileConstants.nameMaxLength) {
      return 'Name must not exceed ${ProfileConstants.nameMaxLength} characters';
    }
    if (!_nameRegex.hasMatch(v)) {
      return "Name can only contain letters, spaces, . ' and -";
    }
    return null;
  }

  static String? gender(Gender? value) =>
      value == null ? 'Please select your gender' : null;

  static String? college(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your college name';
    if (v.length < ProfileConstants.collegeMinLength) {
      return 'College name must be at least ${ProfileConstants.collegeMinLength} characters';
    }
    if (v.length > ProfileConstants.collegeMaxLength) {
      return 'College name must not exceed ${ProfileConstants.collegeMaxLength} characters';
    }
    if (!_textRegex.hasMatch(v)) return 'College name has invalid characters';
    return null;
  }

  static String? department(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your department';
    if (v.length < ProfileConstants.departmentMinLength) {
      return 'Department must be at least ${ProfileConstants.departmentMinLength} characters';
    }
    if (v.length > ProfileConstants.departmentMaxLength) {
      return 'Department must not exceed ${ProfileConstants.departmentMaxLength} characters';
    }
    if (!_textRegex.hasMatch(v)) return 'Department has invalid characters';
    return null;
  }

  static String? year(int? value) =>
      value == null ? 'Please select your year of study' : null;

  static String? studentId(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your student ID';
    if (v.length < ProfileConstants.studentIdMinLength) {
      return 'Student ID must be at least ${ProfileConstants.studentIdMinLength} characters';
    }
    if (v.length > ProfileConstants.studentIdMaxLength) {
      return 'Student ID must not exceed ${ProfileConstants.studentIdMaxLength} characters';
    }
    if (!_studentIdRegex.hasMatch(v)) {
      return 'Only letters, numbers, - and / are allowed';
    }
    return null;
  }

  static String? interests(List<String> value) {
    if (value.length < ProfileConstants.minInterests) {
      return 'Pick at least ${ProfileConstants.minInterests} interests';
    }
    return null;
  }

  static String? photo(PickedPhoto photo) {
    final name = photo.fileName.toLowerCase();
    final okType =
        name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png');
    if (!okType) return 'Photo must be a JPG or PNG';
    if (photo.bytes.length > ProfileConstants.maxPhotoBytes) {
      return 'Photo must be under 5 MB';
    }
    return null;
  }
}
