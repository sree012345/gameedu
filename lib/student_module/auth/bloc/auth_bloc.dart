import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/config/server_config.dart';

import '../constants/auth_constants.dart';
import '../services/firebase_auth_service.dart';
import '../validators/auth_validators.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// One bloc shared by Login, Register and OTP screens.
///
/// Email  -> password sign-in / sign-up -> authenticated.
/// Phone  -> Firebase OTP -> verify -> authenticated.
///
/// Errors:
///  * Validation: ONLY the first invalid field (in screen order) gets an
///    error. It disappears as soon as the user types in that field.
///  * Server (Firebase / network): shown in red under the button.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required FirebaseAuthService authService})
    : _authService = authService,
      super(const AuthState()) {
    // Login
    on<LoginIdentifierChanged>(
      (e, emit) => emit(
        _typing(AuthField.loginIdentifier).copyWith(loginIdentifier: e.value),
      ),
    );
    on<LoginPasswordChanged>(
      (e, emit) => emit(
        _typing(AuthField.loginPassword).copyWith(loginPassword: e.value),
      ),
    );
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginPressed>(_onGoogleLoginPressed);

    // Register
    on<RegisterFullNameChanged>(
      (e, emit) =>
          emit(_typing(AuthField.fullName).copyWith(fullName: e.value)),
    );
    on<RegisterIdentifierChanged>(
      (e, emit) => emit(
        _typing(
          AuthField.registerIdentifier,
        ).copyWith(registerIdentifier: e.value),
      ),
    );
    on<RegisterPasswordChanged>(
      (e, emit) => emit(
        _typing(
          AuthField.registerPassword,
        ).copyWith(registerPassword: e.value),
      ),
    );
    on<RegisterConfirmPasswordChanged>(
      (e, emit) => emit(
        _typing(
          AuthField.registerConfirmPassword,
        ).copyWith(registerConfirmPassword: e.value),
      ),
    );
    on<RegisterCollegeChanged>(
      (e, emit) => emit(_typing(AuthField.college).copyWith(college: e.value)),
    );
    on<RegisterStudentIdChanged>(
      (e, emit) =>
          emit(_typing(AuthField.studentId).copyWith(studentId: e.value)),
    );
    on<RegisterTermsToggled>(
      (e, emit) => emit(
        _typing(AuthField.terms).copyWith(termsAccepted: e.accepted),
      ),
    );
    on<RegisterSubmitted>(_onRegisterSubmitted);

    // OTP
    on<OtpChanged>(
      (e, emit) => emit(_typing(AuthField.otp).copyWith(otp: e.value)),
    );
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<OtpScreenClosed>(_onOtpScreenClosed);
    on<_OtpTicked>(_onOtpTicked);
  }

  final FirebaseAuthService _authService;
  Timer? _resendTimer;
  bool _resending = false;

  // ───────────────────────── error helpers ─────────────────────────

  /// Called while typing: removes this field's error and any server error.
  AuthState _typing(AuthField field) => state.copyWith(
    clearFieldError: state.errorField == field,
    clearServerError: true,
  );

  /// Returns the first non-null message, in the order given.
  AuthFieldError? _firstError(List<(AuthField, String?)> checks) {
    for (final (field, message) in checks) {
      if (message != null) return AuthFieldError(field, message);
    }
    return null;
  }

  void _showFieldError(Emitter<AuthState> emit, AuthFieldError error) {
    emit(
      state.copyWith(
        clearServerError: true,
        errorField: error.field,
        errorMessage: error.message,
      ),
    );
  }

  void _fail(Emitter<AuthState> emit, AuthFailure e) {
    emit(state.copyWith(status: AuthStatus.idle, serverError: e.message));
  }

  // ───────────────────────── Login ─────────────────────────

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isBusy) return;

    final error = _firstError(<(AuthField, String?)>[
      (
        AuthField.loginIdentifier,
        AuthValidators.emailOrMobile(state.loginIdentifier),
      ),
      if (state.loginNeedsPassword)
        (
          AuthField.loginPassword,
          AuthValidators.passwordRequired(state.loginPassword),
        ),
    ]);
    if (error != null) {
      _showFieldError(emit, error);
      return;
    }

    if (state.loginNeedsPassword) {
      // Email -> password
      emit(
        state.copyWith(
          flow: AuthFlow.login,
          method: AuthMethod.email,
          status: AuthStatus.submitting,
          clearFieldError: true,
          clearServerError: true,
        ),
      );
      try {
        await _authService.signInWithEmail(
          email: state.loginIdentifier.trim(),
          password: state.loginPassword,
        );
        if (emit.isDone) return;
        emit(state.copyWith(status: AuthStatus.authenticated));
      } on AuthFailure catch (e) {
        if (emit.isDone) return;
        _fail(emit, e);
      }
    } else {
      // Phone -> OTP
      await _sendOtp(
        emit,
        flow: AuthFlow.login,
        identifier: state.loginIdentifier,
      );
    }
  }

  void _onGoogleLoginPressed(
    GoogleLoginPressed event,
    Emitter<AuthState> emit,
  ) {
    // TODO: connect Google sign-in.
    _showMessage(emit, 'Google sign-in is coming soon');
  }

  // ───────────────────────── Register ─────────────────────────

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isBusy) return;

    // Same order as the screen: first problem wins.
    final error = _firstError(<(AuthField, String?)>[
      (AuthField.fullName, AuthValidators.fullName(state.fullName)),
      (
        AuthField.registerIdentifier,
        AuthValidators.emailOrMobile(state.registerIdentifier),
      ),
      if (state.registerNeedsPassword) ...[
        (
          AuthField.registerPassword,
          AuthValidators.newPassword(state.registerPassword),
        ),
        (
          AuthField.registerConfirmPassword,
          AuthValidators.confirmPassword(
            state.registerPassword,
            state.registerConfirmPassword,
          ),
        ),
      ],
      (AuthField.college, AuthValidators.college(state.college)),
      (AuthField.studentId, AuthValidators.studentId(state.studentId)),
      (AuthField.terms, AuthValidators.terms(state.termsAccepted)),
    ]);
    if (error != null) {
      _showFieldError(emit, error);
      return;
    }

    if (state.registerNeedsPassword) {
      // Email -> create account with password
      final email = state.registerIdentifier.trim();
      emit(
        state.copyWith(
          flow: AuthFlow.register,
          method: AuthMethod.email,
          status: AuthStatus.submitting,
          clearFieldError: true,
          clearServerError: true,
        ),
      );
      try {
        final user = await _authService.registerWithEmail(
          email: email,
          password: state.registerPassword,
          displayName: state.fullName.trim(),
        );
        await _saveProfile(user, email: email);
        if (emit.isDone) return;
        emit(state.copyWith(status: AuthStatus.authenticated));
      } on AuthFailure catch (e) {
        if (emit.isDone) return;
        _fail(emit, e);
      }
    } else {
      // Phone -> OTP (profile is saved after the OTP is verified)
      await _sendOtp(
        emit,
        flow: AuthFlow.register,
        identifier: state.registerIdentifier,
      );
    }
  }

  // ───────────────────────── OTP ─────────────────────────

  Future<void> _sendOtp(
    Emitter<AuthState> emit, {
    required AuthFlow flow,
    required String identifier,
  }) async {
    emit(
      state.copyWith(
        flow: flow,
        method: AuthMethod.phone,
        status: AuthStatus.submitting,
        clearFieldError: true,
        clearServerError: true,
      ),
    );

    try {
      final result = await _authService.sendOtp(
        phoneNumber: AuthValidators.toE164(identifier),
      );
      if (emit.isDone) return;

      emit(
        state.copyWith(
          flow: flow,
          method: AuthMethod.phone,
          status: AuthStatus.otpSent,
          otpTarget: AuthValidators.formatIdentifier(identifier),
          verificationId: result.verificationId,
          resendToken: result.resendToken,
          otp: '',
          resendSeconds: AuthConstants.resendSeconds,
        ),
      );
      _startResendTimer();
    } on AuthFailure catch (e) {
      if (emit.isDone) return;
      _fail(emit, e);
    }
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.verifying) return;

    final otpMessage = AuthValidators.otp(state.otp);
    if (otpMessage != null) {
      _showFieldError(emit, AuthFieldError(AuthField.otp, otpMessage));
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.verifying,
        clearFieldError: true,
        clearServerError: true,
      ),
    );

    try {
      final user = await _authService.verifyOtp(
        verificationId: state.verificationId,
        smsCode: state.otp,
      );
      if (state.flow == AuthFlow.register) {
        await _saveProfile(user, phone: user.phoneNumber);
      }
      if (emit.isDone) return;

      _resendTimer?.cancel();
      emit(state.copyWith(status: AuthStatus.authenticated));
    } on AuthFailure catch (e) {
      if (emit.isDone) return;
      if (e.isInvalidOtp) {
        // Wrong code -> red OTP boxes + message under them
        emit(
          state.copyWith(
            status: AuthStatus.idle,
            errorField: AuthField.otp,
            errorMessage: e.message,
          ),
        );
      } else {
        _fail(emit, e);
      }
    }
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.resendSeconds > 0 || state.isBusy || _resending) return;
    _resending = true;

    final identifier = state.flow == AuthFlow.login
        ? state.loginIdentifier
        : state.registerIdentifier;

    emit(
      state.copyWith(otp: '', clearFieldError: true, clearServerError: true),
    );

    try {
      final result = await _authService.sendOtp(
        phoneNumber: AuthValidators.toE164(identifier),
        resendToken: state.resendToken,
      );
      if (emit.isDone) return;

      emit(
        state.copyWith(
          verificationId: result.verificationId,
          resendToken: result.resendToken,
          resendSeconds: AuthConstants.resendSeconds,
        ),
      );
      _showMessage(emit, 'A new OTP has been sent to ${state.otpTarget}');
      _startResendTimer();
    } on AuthFailure catch (e) {
      if (emit.isDone) return;
      _fail(emit, e);
    } finally {
      _resending = false;
    }
  }

  void _onOtpScreenClosed(OtpScreenClosed event, Emitter<AuthState> emit) {
    _resendTimer?.cancel();
    emit(
      state.copyWith(
        status: AuthStatus.idle,
        otp: '',
        resendSeconds: 0,
        clearFieldError: true,
        clearServerError: true,
      ),
    );
  }

  void _onOtpTicked(_OtpTicked event, Emitter<AuthState> emit) {
    final next = state.resendSeconds - 1;
    if (next <= 0) {
      _resendTimer?.cancel();
      emit(state.copyWith(resendSeconds: 0));
    } else {
      emit(state.copyWith(resendSeconds: next));
    }
  }

  // ───────────────────────── helpers ─────────────────────────

  /// Saves name / college / student ID. A failure here must not block the
  /// user, because the Firebase account already exists.
  Future<void> _saveProfile(User user, {String? email, String? phone}) async {
    try {
      await _authService.saveUserProfile(
        uid: user.uid,
        fullName: state.fullName.trim(),
        college: state.college.trim(),
        studentId: state.studentId.trim(),
        email: email,
        phone: phone,
      );
      debugPrint(
        '[Auth] Profile saved: ${ServerConfig.usersCollection}/${user.uid}',
      );
    } on AuthFailure catch (e) {
      debugPrint('[Auth] Profile save FAILED: code=${e.code} msg=${e.message}');
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _OtpTicked()),
    );
  }

  /// One-shot info message (snackbar), e.g. "OTP resent".
  void _showMessage(Emitter<AuthState> emit, String message) {
    emit(state.copyWith(message: message));
    emit(state.copyWith(clearMessage: true));
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
