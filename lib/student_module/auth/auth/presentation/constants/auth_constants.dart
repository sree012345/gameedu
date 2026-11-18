/// Static values used by the auth feature (limits, timings, demo data).
class AuthConstants {
  AuthConstants._();

  // ── OTP ──
  static const int otpLength = 6;
  static const int resendSeconds = 30;

  /// TODO: remove when a real OTP service is connected.
  /// Until then, this is the only OTP that passes verification.
  static const String mockOtp = '123456';

  /// Fake network delay so the loading state is visible.
  static const Duration mockNetworkDelay = Duration(milliseconds: 900);

  // ── Validation limits ──
  static const int nameMinLength = 2;
  static const int nameMaxLength = 50;
  static const int studentIdMinLength = 4;
  static const int studentIdMaxLength = 20;
  static const int mobileInputMaxLength = 15; // "+91 98765 43210"

  /// Demo data. Replace with API data later.
  static const List<String> colleges = [
    'Sunrise Institute of Technology',
    'Greenfield College of Engineering',
    'Lakeview University',
    'Royal Institute of Management',
    'Nova School of Design',
    "St. Xavier's College",
    'Pinnacle Institute of Science',
  ];
}
