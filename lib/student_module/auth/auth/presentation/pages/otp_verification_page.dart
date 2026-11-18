import 'package:flutter/material.dart';

import 'mobile/mobile_otp_view.dart';

/// Expects an [AuthBloc] above it (provided by `AuthNavigator.toOtp`).
class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) => const MobileOtpView();
}
