import 'package:flutter/material.dart';

import 'views/mobile_otp_view.dart';

/// The shared AuthBloc is provided by `AuthNavigator.toOtp`.
class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) => const MobileOtpView();
}
