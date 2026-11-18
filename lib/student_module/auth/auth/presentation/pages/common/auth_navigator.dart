import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc.dart';
import '../otp_verification_page.dart';
import '../register_page.dart';
import 'auth_next_screen_placeholder.dart';

/// Single place for all auth navigation.
/// The same [AuthBloc] instance is passed to every screen so the typed
/// data (e.g. the OTP target) is shared across the flow.
class AuthNavigator {
  AuthNavigator._();

  static void toRegister(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const RegisterPage()),
      ),
    );
  }

  static void toOtp(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const OtpVerificationPage(),
        ),
      ),
    );
  }

  /// TODO: replace [AuthNextScreenPlaceholder] with your home screen.
  static void toHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const AuthNextScreenPlaceholder(),
      ),
      (route) => false,
    );
  }
}
