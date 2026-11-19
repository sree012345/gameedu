
import '../constants/auth_constants.dart';

/// Identifies whether the user entered an email or phone number.
enum IdentifierType {
  none,
  email,
  phone,
}

class AuthValidators {
  AuthValidators._();

  // ===========================================================================
  // REGULAR EXPRESSIONS
  // ===========================================================================

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );

  static final RegExp _mobileRegex = RegExp(
    r'^[6-9]\d{9}$',
  );

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  static final RegExp _phoneChars = RegExp(
    r'^[\d+\s\-()]+$',
  );

  static final RegExp _nameRegex = RegExp(
    r"^[\p{L}][\p{L} .'\-]*$",
    unicode: true,
  );

  static final RegExp _collegeRegex = RegExp(
    r"^[\p{L}\p{N}][\p{L}\p{N} .,&'()\-/]*$",
    unicode: true,
  );

  static final RegExp _studentIdRegex = RegExp(
    r'^[A-Za-z0-9\-/]+$',
  );

  static final RegExp _hasLetter = RegExp(r'[A-Za-z]');

  static final RegExp _hasDigit = RegExp(r'\d');

  // ===========================================================================
  // FIRST ERROR HANDLING
  // ===========================================================================

  /// Throws the first validation error and stops execution.
  static void _throwIfInvalid(String? error) {
    if (error != null) {
      throw FormatException(error);
    }
  }

  // ===========================================================================
  // EMAIL / PHONE HELPERS
  // ===========================================================================

  static bool isEmail(String value) {
    return _emailRegex.hasMatch(value.trim());
  }

  /// Determines whether an identifier is email or phone.
  static IdentifierType identifierType(String value) {
    final v = value.trim();

    if (v.isEmpty) {
      return IdentifierType.none;
    }

    if (v.contains('@')) {
      return IdentifierType.email;
    }

    if (_phoneChars.hasMatch(v)) {
      return IdentifierType.phone;
    }

    return IdentifierType.none;
  }

  /// Removes phone formatting and Indian country prefixes.
  static String normalizeMobile(String value) {
    var v = value.replaceAll(
      RegExp(r'[\s\-()]'),
      '',
    );

    if (v.startsWith('+91')) {
      v = v.substring(3);
    } else if (v.startsWith('91') && v.length == 12) {
      v = v.substring(2);
    } else if (v.startsWith('0') && v.length == 11) {
      v = v.substring(1);
    }

    return v;
  }

  static bool isMobile(String value) {
    return _mobileRegex.hasMatch(
      normalizeMobile(value),
    );
  }

  /// Converts a valid Indian phone number to E.164 format.
  static String toE164(String value) {
    if (!isMobile(value)) {
      throw const FormatException(
        'Enter a valid 10-digit mobile number',
      );
    }

    return '+91${normalizeMobile(value)}';
  }

  /// Formats identifier for UI display.
  static String formatIdentifier(String value) {
    final v = value.trim();

    if (isEmail(v)) {
      return v;
    }

    if (isMobile(v)) {
      final n = normalizeMobile(v);

      return '+91 ${n.substring(0, 5)} ${n.substring(5)}';
    }

    return v;
  }

  // ===========================================================================
  // EMAIL OR MOBILE VALIDATION
  // ===========================================================================

  static String? emailOrMobile(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return 'Please enter your email or mobile number';
    }

    if (v.contains('@')) {
      if (!isEmail(v)) {
        return 'Enter a valid email address';
      }

      return null;
    }

    final normalized = normalizeMobile(v);

    if (_digitsOnly.hasMatch(normalized)) {
      if (!isMobile(v)) {
        return 'Enter a valid 10-digit mobile number';
      }

      return null;
    }

    return 'Enter a valid email or mobile number';
  }

  /// Validates only an email address.
  static String? email(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return 'Please enter your email address';
    }

    if (!isEmail(v)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validates only an Indian mobile number.
  static String? mobile(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return 'Please enter your mobile number';
    }

    if (!isMobile(v)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  // ===========================================================================
  // PASSWORD VALIDATION
  // ===========================================================================

  /// Login only requires a non-empty password.
  static String? passwordRequired(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }

  /// Validates the strength of a new password.
  static String? newPassword(String? value) {
    final p = value ?? '';

    if (p.isEmpty) {
      return 'Please create a password';
    }

    if (p.length < AuthConstants.passwordMinLength) {
      return 'Password must be at least '
          '${AuthConstants.passwordMinLength} characters';
    }

    if (p.length > AuthConstants.passwordMaxLength) {
      return 'Password must not exceed '
          '${AuthConstants.passwordMaxLength} characters';
    }

    if (p.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    if (!_hasLetter.hasMatch(p)) {
      return 'Password must contain at least one letter';
    }

    if (!_hasDigit.hasMatch(p)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // ===========================================================================
  // CONFIRM PASSWORD VALIDATION
  // ===========================================================================

  static String? confirmPassword(
    String? password,
    String? confirm,
  ) {
    if ((confirm ?? '').isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirm) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ===========================================================================
  // FULL NAME VALIDATION
  // ===========================================================================

  static String? fullName(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return 'Please enter your full name';
    }

    if (v.length < AuthConstants.nameMinLength) {
      return 'Name must be at least '
          '${AuthConstants.nameMinLength} characters';
    }

    if (v.length > AuthConstants.nameMaxLength) {
      return 'Name must not exceed '
          '${AuthConstants.nameMaxLength} characters';
    }

    if (!_nameRegex.hasMatch(v)) {
      return "Name can only contain letters, spaces, . ' and -";
    }

    return null;
  }

  // ===========================================================================
  // COLLEGE VALIDATION
  // ===========================================================================

  static String? college(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return 'Please enter your college name';
    }

    if (v.length < AuthConstants.collegeMinLength) {
      return 'College name must be at least '
          '${AuthConstants.collegeMinLength} characters';
    }

    if (v.length > AuthConstants.collegeMaxLength) {
      return 'College name must not exceed '
          '${AuthConstants.collegeMaxLength} characters';
    }

    if (!_collegeRegex.hasMatch(v)) {
      return 'College name has invalid characters';
    }

    return null;
  }

  // ===========================================================================
  // STUDENT ID VALIDATION
  // ===========================================================================

  static String? studentId(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return 'Please enter your student ID';
    }

    if (v.length < AuthConstants.studentIdMinLength) {
      return 'Student ID must be at least '
          '${AuthConstants.studentIdMinLength} characters';
    }

    if (v.length > AuthConstants.studentIdMaxLength) {
      return 'Student ID must not exceed '
          '${AuthConstants.studentIdMaxLength} characters';
    }

    if (!_studentIdRegex.hasMatch(v)) {
      return 'Only letters, numbers, - and / are allowed';
    }

    return null;
  }

  // ===========================================================================
  // TERMS & CONDITIONS
  // ===========================================================================

  static String? terms(bool accepted) {
    if (!accepted) {
      return 'Please accept the Terms of Use and Privacy Policy';
    }

    return null;
  }

  // ===========================================================================
  // OTP VALIDATION
  // ===========================================================================

  static String? otp(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return 'Please enter your OTP';
    }

    if (v.length != AuthConstants.otpLength) {
      return 'OTP must contain '
          '${AuthConstants.otpLength} digits';
    }

    if (!_digitsOnly.hasMatch(v)) {
      return 'OTP must contain numbers only';
    }

    return null;
  }

  // ===========================================================================
  // LOGIN VALIDATION
  // ===========================================================================

  /// Email -> Validate email and password.
  /// Phone -> Validate phone number; OTP comes next.
  static void validateLogin({
    required String identifier,
    required String password,
  }) {
    // Step 1: Identifier
    _throwIfInvalid(emailOrMobile(identifier));

    // Step 2: Password only for email login
    if (identifierType(identifier) == IdentifierType.email) {
      _throwIfInvalid(passwordRequired(password));
    }
  }

  // ===========================================================================
  // REGISTRATION VALIDATION
  // ===========================================================================

  /// Validates every field in sequence.
  /// Only the first invalid field throws an error.
  static void validateRegistration({
    required String name,
    required String emailOrPhone,
    required String password,
    required String confirmPasswordValue,
    required String collegeName,
    required String studentIdValue,
    required bool acceptedTerms,
  }) {
    // Step 1: Full name
    _throwIfInvalid(fullName(name));

    // Step 2: Email or phone
    _throwIfInvalid(emailOrMobile(emailOrPhone));

    // Step 3: Password for email registration
    if (identifierType(emailOrPhone) == IdentifierType.email) {
      _throwIfInvalid(newPassword(password));

      // Step 4: Confirm password
      _throwIfInvalid(
        confirmPassword(password, confirmPasswordValue),
      );
    }

    // Step 5: College name
    _throwIfInvalid(college(collegeName));

    // Step 6: Student ID
    _throwIfInvalid(studentId(studentIdValue));

    // Step 7: Terms
    _throwIfInvalid(terms(acceptedTerms));
  }

  // ===========================================================================
  // OTP VERIFICATION VALIDATION
  // ===========================================================================

  static void validateOtp({
    required String value,
  }) {
    _throwIfInvalid(otp(value));
  }

  // ===========================================================================
  // FORGOT PASSWORD VALIDATION
  // ===========================================================================

  static void validateForgotPassword({
    required String identifier,
  }) {
    _throwIfInvalid(emailOrMobile(identifier));
  }

  // ===========================================================================
  // RESET PASSWORD VALIDATION
  // ===========================================================================

  static void validateResetPassword({
    required String password,
    required String confirmPasswordValue,
  }) {
    _throwIfInvalid(newPassword(password));

    _throwIfInvalid(
      confirmPassword(password, confirmPasswordValue),
    );
  }

  // ===========================================================================
  // STUDENT PROFILE VALIDATION
  // ===========================================================================

  static void validateStudentProfile({
    required String name,
    required String collegeName,
    required String studentIdValue,
  }) {
    _throwIfInvalid(fullName(name));

    _throwIfInvalid(college(collegeName));

    _throwIfInvalid(studentId(studentIdValue));
  }
}
