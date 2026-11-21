/// Validators for adding a missing email / mobile number.
/// Both are optional: an empty value means "don't add".
class ContactValidators {
  ContactValidators._();

  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );
  static final RegExp _mobile = RegExp(r'^[6-9]\d{9}$');

  static String? optionalEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _email.hasMatch(v) ? null : 'Enter a valid email address';
  }

  static String? optionalMobile(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _mobile.hasMatch(v) ? null : 'Enter a valid 10-digit mobile number';
  }

  /// "9876543210" -> "+919876543210"
  static String toE164(String digits) => '+91${digits.trim()}';
}
