import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/student_module/splash/services/startup_service.dart';

import '../../bloc/auth_bloc.dart';
import '../otp_verification_page.dart';
import '../register_page.dart';

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

  /// After a successful sign-in: open the dashboard (named route) and
  /// clear the whole auth stack.
 
  /// After a successful sign-in / registration:
  ///  * no profile + login flow     -> sign out, show "register first"
  ///  * profile, onboarding pending -> Create Profile
  ///  * profile, onboarding done    -> Dashboard
static Future<void> toHome(BuildContext context) async {
  if (FirebaseAuth.instance.currentUser == null) {
    _showError(context, 'Please login first.');
    return;
  }

  final isRegistration = context.read<AuthBloc>().state.flow != AuthFlow.login;
  final messenger = ScaffoldMessenger.maybeOf(context);

  try {
    final route = await StartupService().resolveNextRoute(
      isRegistration: isRegistration,
    );

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil<void>(route, (_) => false);
    }

    if (route == RouterPath.authWrapper &&
        !isRegistration &&
        messenger != null &&
        messenger.mounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No account found. Please register first.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } on FirebaseException catch (e) {
    _showError(context, 'Unable to load profile: ${e.message ?? e.code}');
  }
}
static void _showError(
  BuildContext context,
  String message,
) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
}

