import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/auth_constants.dart';
import '../validators/auth_validators.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// One bloc shared by Login, Register and OTP screens.
///
/// There is no repository / data source yet. Sending and verifying the OTP
/// are simulated locally with [AuthConstants.mockNetworkDelay]. Replace
/// [_requestOtp] and the check inside [_onOtpSubmitted] when the real
/// service is ready.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    // Login
    on<LoginIdentifierChanged>(_onLoginIdentifierChanged);
    on<LoginMethodChanged>(_onLoginMethodChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginPressed>(_onGoogleLoginPressed);

    // Register
    on<RegisterFullNameChanged>(
      (e, emit) => emit(state.copyWith(fullName: e.value)),
    );
    on<RegisterIdentifierChanged>(
      (e, emit) => emit(state.copyWith(registerIdentifier: e.value)),
    );
    on<RegisterCollegeSelected>(
      (e, emit) => emit(state.copyWith(college: e.value)),
    );
    on<RegisterStudentIdChanged>(
      (e, emit) => emit(state.copyWith(studentId: e.value)),
    );
    on<RegisterTermsToggled>(
      (e, emit) => emit(state.copyWith(termsAccepted: e.accepted)),
    );
    on<RegisterSubmitted>(_onRegisterSubmitted);

    // OTP
    on<OtpChanged>(_onOtpChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<OtpScreenClosed>(_onOtpScreenClosed);
    on<_OtpTicked>(_onOtpTicked);
  }

  Timer? _resendTimer;

  // ───────────────────────── Login ─────────────────────────

  void _onLoginIdentifierChanged(
    LoginIdentifierChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(loginIdentifier: event.value));
  }

  void _onLoginMethodChanged(
    LoginMethodChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        isMobileMode: event.isMobile,
        loginIdentifier: '',
        loginSubmitted: false,
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) return;

    emit(state.copyWith(loginSubmitted: true));
    if (!state.isLoginValid) return;

    await _requestOtp(
      emit,
      flow: AuthFlow.login,
      identifier: state.loginIdentifier,
    );
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
    if (state.status == AuthStatus.submitting) return;

    emit(state.copyWith(registerSubmitted: true));
    if (!state.isRegisterValid) return;

    await _requestOtp(
      emit,
      flow: AuthFlow.register,
      identifier: state.registerIdentifier,
    );
  }

  // ───────────────────────── OTP ─────────────────────────

  /// Simulates "send OTP". Replace with the real call later.
  Future<void> _requestOtp(
    Emitter<AuthState> emit, {
    required AuthFlow flow,
    required String identifier,
  }) async {
    emit(state.copyWith(flow: flow, status: AuthStatus.submitting));

    await Future<void>.delayed(AuthConstants.mockNetworkDelay);

    emit(
      state.copyWith(
        flow: flow,
        status: AuthStatus.otpSent,
        otpTarget: AuthValidators.formatIdentifier(identifier),
        otp: '',
        otpSubmitted: false,
        otpIncorrect: false,
        resendSeconds: AuthConstants.resendSeconds,
      ),
    );
    _startResendTimer();
    _logMockOtp();
  }

  void _onOtpChanged(OtpChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(otp: event.value, otpIncorrect: false));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.verifying) return;

    emit(state.copyWith(otpSubmitted: true));
    if (AuthValidators.otp(state.otp) != null) return;

    emit(state.copyWith(status: AuthStatus.verifying));
    await Future<void>.delayed(AuthConstants.mockNetworkDelay);

    // TODO: replace with the real verification call.
    if (state.otp != AuthConstants.mockOtp) {
      emit(state.copyWith(status: AuthStatus.idle, otpIncorrect: true));
      return;
    }

    _resendTimer?.cancel();
    emit(state.copyWith(status: AuthStatus.verified));
  }

  void _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<AuthState> emit,
  ) {
    if (state.resendSeconds > 0) return;

    emit(
      state.copyWith(
        otp: '',
        otpSubmitted: false,
        otpIncorrect: false,
        resendSeconds: AuthConstants.resendSeconds,
      ),
    );
    _showMessage(emit, 'A new OTP has been sent to ${state.otpTarget}');
    _startResendTimer();
    _logMockOtp();
  }

  void _onOtpScreenClosed(OtpScreenClosed event, Emitter<AuthState> emit) {
    _resendTimer?.cancel();
    emit(
      state.copyWith(
        status: AuthStatus.idle,
        otp: '',
        otpSubmitted: false,
        otpIncorrect: false,
        resendSeconds: 0,
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

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _OtpTicked()),
    );
  }

  /// Emits a one-shot message, then clears it so the same message can be
  /// shown again later.
  void _showMessage(Emitter<AuthState> emit, String message) {
    emit(state.copyWith(message: message));
    emit(state.copyWith(clearMessage: true));
  }

  void _logMockOtp() {
    if (kDebugMode) debugPrint('[Auth] Mock OTP: ${AuthConstants.mockOtp}');
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
