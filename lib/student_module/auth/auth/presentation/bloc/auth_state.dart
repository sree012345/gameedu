part of 'auth_bloc.dart';

/// Which form started the OTP request. Used so only the correct screen
/// reacts when the OTP is sent (Login and Register both stay in the stack).
enum AuthFlow { login, register }

enum AuthStatus {
  idle,

  /// Sending OTP (Login / Register button loading)
  submitting,

  /// OTP sent. One-shot trigger to open the OTP screen.
  otpSent,

  /// Verifying OTP (Verify button loading)
  verifying,

  /// OTP correct. One-shot trigger to open the next screen.
  verified,
}

final class AuthState extends Equatable {
  const AuthState({
    this.flow = AuthFlow.login,
    this.status = AuthStatus.idle,
    // login
    this.isMobileMode = false,
    this.loginIdentifier = '',
    this.loginSubmitted = false,
    // register
    this.fullName = '',
    this.registerIdentifier = '',
    this.college = '',
    this.studentId = '',
    this.termsAccepted = false,
    this.registerSubmitted = false,
    // otp
    this.otp = '',
    this.otpSubmitted = false,
    this.otpIncorrect = false,
    this.otpTarget = '',
    this.resendSeconds = 0,
    // one-shot snackbar message
    this.message,
  });

  final AuthFlow flow;
  final AuthStatus status;

  // Login
  final bool isMobileMode;
  final String loginIdentifier;
  final bool loginSubmitted;

  // Register
  final String fullName;
  final String registerIdentifier;
  final String college;
  final String studentId;
  final bool termsAccepted;
  final bool registerSubmitted;

  // OTP
  final String otp;
  final bool otpSubmitted;
  final bool otpIncorrect;
  final String otpTarget;
  final int resendSeconds;

  final String? message;

  // ───────────── loading flags ─────────────

  bool get isLoginLoading =>
      status == AuthStatus.submitting && flow == AuthFlow.login;

  bool get isRegisterLoading =>
      status == AuthStatus.submitting && flow == AuthFlow.register;

  bool get isVerifying => status == AuthStatus.verifying;

  // ───────────── validity (used by the bloc on submit) ─────────────

  bool get isLoginValid =>
      AuthValidators.emailOrMobile(loginIdentifier, mobileOnly: isMobileMode) ==
      null;

  bool get isRegisterValid =>
      AuthValidators.fullName(fullName) == null &&
      AuthValidators.emailOrMobile(registerIdentifier) == null &&
      AuthValidators.college(college) == null &&
      AuthValidators.studentId(studentId) == null &&
      AuthValidators.terms(termsAccepted) == null;

  // ───────────── errors shown in the UI ─────────────
  // Errors only appear after the first submit attempt, then update live.

  String? get loginIdentifierError => loginSubmitted
      ? AuthValidators.emailOrMobile(loginIdentifier, mobileOnly: isMobileMode)
      : null;

  String? get fullNameError =>
      registerSubmitted ? AuthValidators.fullName(fullName) : null;

  String? get registerIdentifierError => registerSubmitted
      ? AuthValidators.emailOrMobile(registerIdentifier)
      : null;

  String? get collegeError =>
      registerSubmitted ? AuthValidators.college(college) : null;

  String? get studentIdError =>
      registerSubmitted ? AuthValidators.studentId(studentId) : null;

  String? get termsError =>
      registerSubmitted ? AuthValidators.terms(termsAccepted) : null;

  String? get otpError {
    if (otpIncorrect) return 'Incorrect OTP. Please try again.';
    return otpSubmitted ? AuthValidators.otp(otp) : null;
  }

  AuthState copyWith({
    AuthFlow? flow,
    AuthStatus? status,
    bool? isMobileMode,
    String? loginIdentifier,
    bool? loginSubmitted,
    String? fullName,
    String? registerIdentifier,
    String? college,
    String? studentId,
    bool? termsAccepted,
    bool? registerSubmitted,
    String? otp,
    bool? otpSubmitted,
    bool? otpIncorrect,
    String? otpTarget,
    int? resendSeconds,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      flow: flow ?? this.flow,
      status: status ?? this.status,
      isMobileMode: isMobileMode ?? this.isMobileMode,
      loginIdentifier: loginIdentifier ?? this.loginIdentifier,
      loginSubmitted: loginSubmitted ?? this.loginSubmitted,
      fullName: fullName ?? this.fullName,
      registerIdentifier: registerIdentifier ?? this.registerIdentifier,
      college: college ?? this.college,
      studentId: studentId ?? this.studentId,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      registerSubmitted: registerSubmitted ?? this.registerSubmitted,
      otp: otp ?? this.otp,
      otpSubmitted: otpSubmitted ?? this.otpSubmitted,
      otpIncorrect: otpIncorrect ?? this.otpIncorrect,
      otpTarget: otpTarget ?? this.otpTarget,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    flow,
    status,
    isMobileMode,
    loginIdentifier,
    loginSubmitted,
    fullName,
    registerIdentifier,
    college,
    studentId,
    termsAccepted,
    registerSubmitted,
    otp,
    otpSubmitted,
    otpIncorrect,
    otpTarget,
    resendSeconds,
    message,
  ];
}
