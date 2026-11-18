import 'package:flutter/material.dart';

import 'mobile/mobile_register_view.dart';

/// Expects an [AuthBloc] above it (provided by `AuthNavigator.toRegister`).
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const MobileRegisterView();
}
