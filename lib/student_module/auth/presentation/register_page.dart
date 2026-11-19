import 'package:flutter/material.dart';

import 'views/mobile_register_view.dart';

/// The shared AuthBloc is provided by `AuthNavigator.toRegister`.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const MobileRegisterView();
}
