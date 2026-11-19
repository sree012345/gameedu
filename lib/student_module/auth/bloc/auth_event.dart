part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ───────────────────────── Login ─────────────────────────

final class LoginIdentifierChanged extends AuthEvent {
  const LoginIdentifierChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class LoginPasswordChanged extends AuthEvent {
  const LoginPasswordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class LoginSubmitted extends AuthEvent {
  const LoginSubmitted();
}

final class GoogleLoginPressed extends AuthEvent {
  const GoogleLoginPressed();
}

// ───────────────────────── Register ─────────────────────────

final class RegisterFullNameChanged extends AuthEvent {
  const RegisterFullNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterIdentifierChanged extends AuthEvent {
  const RegisterIdentifierChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterPasswordChanged extends AuthEvent {
  const RegisterPasswordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterConfirmPasswordChanged extends AuthEvent {
  const RegisterConfirmPasswordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

/// College is now typed by the user (no picker).
final class RegisterCollegeChanged extends AuthEvent {
  const RegisterCollegeChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterStudentIdChanged extends AuthEvent {
  const RegisterStudentIdChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterTermsToggled extends AuthEvent {
  const RegisterTermsToggled(this.accepted);
  final bool accepted;

  @override
  List<Object?> get props => [accepted];
}

final class RegisterSubmitted extends AuthEvent {
  const RegisterSubmitted();
}

// ───────────────────────── OTP ─────────────────────────

final class OtpChanged extends AuthEvent {
  const OtpChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class OtpSubmitted extends AuthEvent {
  const OtpSubmitted();
}

final class OtpResendRequested extends AuthEvent {
  const OtpResendRequested();
}

/// Fired when the OTP screen is closed so timer and OTP state are reset.
final class OtpScreenClosed extends AuthEvent {
  const OtpScreenClosed();
}

/// Internal: fired every second by the resend countdown timer.
final class _OtpTicked extends AuthEvent {
  const _OtpTicked();
}
