import 'package:flutter/material.dart';
import '../bloc/auth_bloc.dart';
import 'views/mobile_login_view.dart';

/// Entry point of the auth flow. Creates the one [AuthBloc] that is shared
/// with Register and OTP via `AuthNavigator`.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileLoginView();
  }
}
