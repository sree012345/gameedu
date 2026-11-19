import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';
import '../../bloc/auth_bloc.dart';
import '../../constants/auth_constants.dart';
import '../../validators/auth_validators.dart';
import '../common/auth_assets.dart';
import '../common/auth_common_widgets.dart';
import '../common/auth_server_error.dart';
import '../common/auth_navigator.dart';
import '../common/auth_scaffold.dart';
import '../common/otp_input_field.dart';

class MobileOtpView extends StatefulWidget {
  const MobileOtpView({super.key});

  @override
  State<MobileOtpView> createState() => _MobileOtpViewState();
}

class _MobileOtpViewState extends State<MobileOtpView> {
  late final AuthBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AuthBloc>();
  }

  @override
  void dispose() {
    // Reset timer + OTP state when leaving this screen.
    if (!_bloc.isClosed) _bloc.add(const OtpScreenClosed());
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // OTP correct -> next screen
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != c.status &&
              c.status == AuthStatus.authenticated &&
              c.method == AuthMethod.phone,
          listener: (context, state) => AuthNavigator.toHome(context),
        ),
        // One-shot messages (e.g. OTP resent)
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) => c.message != null && p.message != c.message,
          listener: (context, state) => showAuthMessage(context, state.message!),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bloc = context.read<AuthBloc>();
          final isEmail = AuthValidators.isEmail(state.otpTarget);
          final error = state.otpError;

          return AuthScaffold(
            hero: const AuthHeroImage(
              asset: AuthAssets.otpHero,
              fallbackIcon: Icons.mark_email_unread_outlined,
              height: 150,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthTitle(
                  title: 'Verify Your',
                  highlight: 'Account',
                  subtitle: 'Enter the ${AuthConstants.otpLength}-digit OTP sent to',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        state.otpTarget,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit -> go back and change the number / email
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppPalette.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OtpInputField(
                  value: state.otp,
                  length: AuthConstants.otpLength,
                  hasError: error != null,
                  onChanged: (v) => bloc.add(OtpChanged(v)),
                  onSubmitted: (_) => bloc.add(const OtpSubmitted()),
                ),
                if (error != null) AuthErrorText(error, center: true),
                const SizedBox(height: 20),
                _ResendRow(
                  seconds: state.resendSeconds,
                  timeText: _formatTime(state.resendSeconds),
                  onResend: () => bloc.add(const OtpResendRequested()),
                ),
                const SizedBox(height: 24),
                MediumButton(
                  text: 'Verify & Continue',
                  isLoading: state.isVerifying,
                  onPressed: () => bloc.add(const OtpSubmitted()),
                ),
                AuthServerError(message: state.serverError),
                const SizedBox(height: 22),
                AuthInfoCard(
                  title: 'Your ${isEmail ? 'email' : 'number'} is only used to verify',
                  message: 'your account. We never share it.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.seconds,
    required this.timeText,
    required this.onResend,
  });

  final int seconds;
  final String timeText;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 14,
      color: AppPalette.authTextSecondaryColor,
    );

    if (seconds > 0) {
      return Text(
        "Didn't receive the OTP? Resend in $timeText",
        textAlign: TextAlign.center,
        style: style,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Didn't receive the OTP? ", style: style),
        InkWell(
          onTap: onResend,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'Resend',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppPalette.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
