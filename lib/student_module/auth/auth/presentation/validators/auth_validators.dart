import '../constants/auth_constants.dart';

/// Pure local validation helpers. Each returns `null` when valid,
/// otherwise the error message to show under the field.
class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );
  static final RegExp _mobileRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _nameRegex = RegExp(
    r"^[\p{L}][\p{L} .'\-]*$",
    unicode: true,
  );
  static final RegExp _studentIdRegex = RegExp(r'^[A-Za-z0-9\-/]+$');

  // ───────────── helpers ─────────────

  static bool isEmail(String value) => _emailRegex.hasMatch(value.trim());

  /// Removes spaces, dashes, brackets and the +91 / 91 / 0 prefix.
  static String normalizeMobile(String value) {
    var v = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (v.startsWith('+91')) {
      v = v.substring(3);
    } else if (v.startsWith('91') && v.length == 12) {
      v = v.substring(2);
    } else if (v.startsWith('0') && v.length == 11) {
      v = v.substring(1);
    }
    return v;
  }

  static bool isMobile(String value) =>
      _mobileRegex.hasMatch(normalizeMobile(value));

  /// Email stays as typed, mobile becomes "+91 98765 43210".
  static String formatIdentifier(String value) {
    final v = value.trim();
    if (isEmail(v)) return v;
    if (isMobile(v)) {
      final n = normalizeMobile(v);
      return '+91 ${n.substring(0, 5)} ${n.substring(5)}';
    }
    return v;
  }

  // ───────────── validators ─────────────

  static String? emailOrMobile(String? value, {bool mobileOnly = false}) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return mobileOnly
          ? 'Please enter your mobile number'
          : 'Please enter your email or mobile number';
    }
    if (mobileOnly) {
      return isMobile(v) ? null : 'Enter a valid 10-digit mobile number';
    }
    if (v.contains('@')) {
      return isEmail(v) ? null : 'Enter a valid email address';
    }
    if (_digitsOnly.hasMatch(normalizeMobile(v))) {
      return isMobile(v) ? null : 'Enter a valid 10-digit mobile number';
    }
    return 'Enter a valid email or mobile number';
  }

  static String? fullName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your full name';
    if (v.length < AuthConstants.nameMinLength) return 'Name is too short';
    if (v.length > AuthConstants.nameMaxLength) return 'Name is too long';
    if (!_nameRegex.hasMatch(v)) {
      return "Name can only contain letters, spaces, . ' and -";
    }
    return null;
  }

  static String? college(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Please select your college';
    return null;
  }

  static String? studentId(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your student ID';
    if (v.length < AuthConstants.studentIdMinLength ||
        v.length > AuthConstants.studentIdMaxLength) {
      return 'Student ID must be '
          '${AuthConstants.studentIdMinLength}-${AuthConstants.studentIdMaxLength} characters';
    }
    if (!_studentIdRegex.hasMatch(v)) {
      return 'Only letters, numbers, - and / are allowed';
    }
    return null;
  }

  static String? terms(bool accepted) =>
      accepted ? null : 'Please accept the Terms of Use and Privacy Policy';

  static String? otp(String? value) {
    final v = value ?? '';
    if (v.length != AuthConstants.otpLength || !_digitsOnly.hasMatch(v)) {
      return 'Enter the ${AuthConstants.otpLength}-digit OTP';
    }
    return null;
  }
}
