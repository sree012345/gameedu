part of 'auth_bloc.dart';

/// Which form started the request.
enum AuthFlow { login, register }

/// How the user is signing in. Email -> password, Phone -> OTP.
enum AuthMethod { email, phone }

enum AuthStatus {
  idle,

  /// Login / Register button loading (email sign-in or sending OTP)
  submitting,

  /// OTP sent. One-shot trigger to open the OTP screen.
  otpSent,

  /// Verifying OTP (Verify button loading)
  verifying,

  /// Firebase signed the user in. One-shot trigger to open the next screen.
  authenticated,
}

/// Every field that can show a validation error.
enum AuthField {
  loginIdentifier,
  loginPassword,
  fullName,
  registerIdentifier,
  registerPassword,
  registerConfirmPassword,
  college,
  studentId,
  terms,
  otp,
}

/// The first invalid field and its message.
final class AuthFieldError {
  const AuthFieldError(this.field, this.message);

  final AuthField field;
  final String message;
}

final class AuthState extends Equatable {
  const AuthState({
    this.flow = AuthFlow.login,
    this.method = AuthMethod.email,
    this.status = AuthStatus.idle,
    // login
    this.loginIdentifier = '',
    this.loginPassword = '',
    // register
    this.fullName = '',
    this.registerIdentifier = '',
    this.registerPassword = '',
    this.registerConfirmPassword = '',
    this.college = '',
    this.studentId = '',
    this.termsAccepted = false,
    // otp
    this.otp = '',
    this.otpTarget = '',
    this.verificationId = '',
    this.resendToken,
    this.resendSeconds = 0,
    // errors (only ONE field error at a time)
    this.errorField,
    this.errorMessage,
    this.serverError,
    // one-shot snackbar message (not an error)
    this.message,
  });

  final AuthFlow flow;
  final AuthMethod method;
  final AuthStatus status;

  // Login
  final String loginIdentifier;
  final String loginPassword;

  // Register
  final String fullName;
  final String registerIdentifier;
  final String registerPassword;
  final String registerConfirmPassword;
  final String college;
  final String studentId;
  final bool termsAccepted;

  // OTP
  final String otp;
  final String otpTarget;
  final String verificationId;
  final int? resendToken;
  final int resendSeconds;

  // Errors
  final AuthField? errorField;
  final String? errorMessage;

  /// Firebase / network error, shown in red under the button.
  final String? serverError;

  final String? message;

  // ───────────── loading flags ─────────────

  bool get isLoginLoading =>
      status == AuthStatus.submitting && flow == AuthFlow.login;

  bool get isRegisterLoading =>
      status == AuthStatus.submitting && flow == AuthFlow.register;

  bool get isVerifying => status == AuthStatus.verifying;

  bool get isBusy =>
      status == AuthStatus.submitting || status == AuthStatus.verifying;

  // ───────────── email or phone? ─────────────

  IdentifierType get loginType => AuthValidators.identifierType(loginIdentifier);
  IdentifierType get registerType =>
      AuthValidators.identifierType(registerIdentifier);

  /// Password field is shown only when the user typed an email.
  bool get loginNeedsPassword => loginType == IdentifierType.email;
  bool get registerNeedsPassword => registerType == IdentifierType.email;

  // ───────────── errors shown in the UI ─────────────

  String? _errorFor(AuthField field) =>
      errorField == field ? errorMessage : null;

  String? get loginIdentifierError => _errorFor(AuthField.loginIdentifier);
  String? get loginPasswordError => _errorFor(AuthField.loginPassword);
  String? get fullNameError => _errorFor(AuthField.fullName);
  String? get registerIdentifierError => _errorFor(AuthField.registerIdentifier);
  String? get registerPasswordError => _errorFor(AuthField.registerPassword);
  String? get registerConfirmPasswordError =>
      _errorFor(AuthField.registerConfirmPassword);
  String? get collegeError => _errorFor(AuthField.college);
  String? get studentIdError => _errorFor(AuthField.studentId);
  String? get termsError => _errorFor(AuthField.terms);
  String? get otpError => _errorFor(AuthField.otp);

  /// Server error, only on the screen that started the request.
  String? get loginServerError => flow == AuthFlow.login ? serverError : null;
  String? get registerServerError =>
      flow == AuthFlow.register ? serverError : null;

  AuthState copyWith({
    AuthFlow? flow,
    AuthMethod? method,
    AuthStatus? status,
    String? loginIdentifier,
    String? loginPassword,
    String? fullName,
    String? registerIdentifier,
    String? registerPassword,
    String? registerConfirmPassword,
    String? college,
    String? studentId,
    bool? termsAccepted,
    String? otp,
    String? otpTarget,
    String? verificationId,
    int? resendToken,
    int? resendSeconds,
    AuthField? errorField,
    String? errorMessage,
    String? serverError,
    String? message,
    bool clearFieldError = false,
    bool clearServerError = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      flow: flow ?? this.flow,
      method: method ?? this.method,
      status: status ?? this.status,
      loginIdentifier: loginIdentifier ?? this.loginIdentifier,
      loginPassword: loginPassword ?? this.loginPassword,
      fullName: fullName ?? this.fullName,
      registerIdentifier: registerIdentifier ?? this.registerIdentifier,
      registerPassword: registerPassword ?? this.registerPassword,
      registerConfirmPassword:
          registerConfirmPassword ?? this.registerConfirmPassword,
      college: college ?? this.college,
      studentId: studentId ?? this.studentId,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      otp: otp ?? this.otp,
      otpTarget: otpTarget ?? this.otpTarget,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      errorField: clearFieldError ? null : (errorField ?? this.errorField),
      errorMessage: clearFieldError ? null : (errorMessage ?? this.errorMessage),
      serverError: clearServerError ? null : (serverError ?? this.serverError),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    flow,
    method,
    status,
    loginIdentifier,
    loginPassword,
    fullName,
    registerIdentifier,
    registerPassword,
    registerConfirmPassword,
    college,
    studentId,
    termsAccepted,
    otp,
    otpTarget,
    verificationId,
    resendToken,
    resendSeconds,
    errorField,
    errorMessage,
    serverError,
    message,
  ];
}
