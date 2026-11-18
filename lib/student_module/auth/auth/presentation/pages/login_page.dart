import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import 'mobile/mobile_login_view.dart';

/// Entry point of the auth flow. Creates the [AuthBloc] that is shared with
/// Register and OTP screens.
///
/// Only the mobile layout exists for now. When tablet / desktop designs are
/// ready, pick the view here based on screen width.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: const MobileLoginView(),
    );
  }
}
