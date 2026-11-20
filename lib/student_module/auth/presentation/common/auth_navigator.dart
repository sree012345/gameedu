import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/config/server_config.dart';
import 'package:game_edu/core/routes/router_path.dart';

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
 
static Future<void> toHome(BuildContext context) async {
  debugPrint('========== AUTH NAVIGATOR TO HOME ==========');

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (context.mounted) {
      _showError(context, 'Please login first.');
    }
    return;
  }

  try {
    debugPrint('Checking profile for UID: ${user.uid}');

    final doc = await FirebaseFirestore.instance
        .collection(ServerConfig.usersCollection)
        .doc(user.uid)
        .get();

    if (!context.mounted) return;

    debugPrint('Profile exists: ${doc.exists}');

    if (!doc.exists) {
      _showError(
        context,
        'User profile not found. Please complete registration.',
      );
      return;
    }

    debugPrint('✅ Profile found. Navigating to Dashboard');

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      RouterPath.home,
      (route) => false,
    );
  } on FirebaseException catch (e) {
    debugPrint('❌ Navigation failed: ${e.code}');

    if (!context.mounted) return;

    _showError(
      context,
      'Unable to load profile: ${e.message ?? e.code}',
    );
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

