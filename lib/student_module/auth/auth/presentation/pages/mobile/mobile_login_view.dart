import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';


import '../../bloc/auth_bloc.dart';
import '../../constants/auth_constants.dart';
import '../common/auth_assets.dart';
import '../common/auth_common_widgets.dart';
import '../common/auth_navigator.dart';
import '../common/auth_scaffold.dart';
import '../common/auth_text_field.dart';

class MobileLoginView extends StatefulWidget {
  const MobileLoginView({super.key});

  @override
  State<MobileLoginView> createState() => _MobileLoginViewState();
}

class _MobileLoginViewState extends State<MobileLoginView> {
  final TextEditingController _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _toggleMethod(bool isMobileMode) {
    _identifierController.clear();
    context.read<AuthBloc>().add(LoginMethodChanged(isMobile: !isMobileMode));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // OTP sent from the Login form -> open OTP screen
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != c.status &&
              c.status == AuthStatus.otpSent &&
              c.flow == AuthFlow.login,
          listener: (context, state) => AuthNavigator.toOtp(context),
        ),
        // One-shot messages (e.g. Google coming soon)
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) => c.message != null && p.message != c.message,
          listener: (context, state) => showAuthMessage(context, state.message!),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bloc = context.read<AuthBloc>();
          final isMobile = state.isMobileMode;

          return AuthScaffold(
            showBack: Navigator.of(context).canPop(),
            hero: const AuthHeroImage(
              asset: AuthAssets.loginHero,
              fallbackIcon: Icons.sports_esports_rounded,
              height: 210,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthTitle(
                  title: 'Welcome',
                  highlight: 'Back',
                  subtitle: 'Login with your email or mobile number',
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: isMobile ? 'Mobile Number' : 'Email or Mobile Number',
                  hint: isMobile ? 'Enter mobile number' : 'Enter email or mobile',
                  prefixIcon: isMobile
                      ? Icons.phone_outlined
                      : Icons.mail_outline_rounded,
                  controller: _identifierController,
                  keyboardType: isMobile
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  inputFormatters: isMobile
                      ? [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                          LengthLimitingTextInputFormatter(
                            AuthConstants.mobileInputMaxLength,
                          ),
                        ]
                      : null,
                  errorText: state.loginIdentifierError,
                  onChanged: (v) => bloc.add(LoginIdentifierChanged(v)),
                  onSubmitted: (_) => bloc.add(const LoginSubmitted()),
                ),
                const SizedBox(height: 24),
                MediumButton(
                  text: 'Send OTP',
                  isLoading: state.isLoginLoading,
                  onPressed: () => bloc.add(const LoginSubmitted()),
                ),
                const SizedBox(height: 26),
                const AuthDivider(text: 'or continue with'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AuthSocialButton(
                        label: 'Google',
                        icon: Icons.language_rounded,
                        onTap: () => bloc.add(const GoogleLoginPressed()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthSocialButton(
                        label: isMobile ? 'Email' : 'Mobile',
                        icon: isMobile
                            ? Icons.mail_outline_rounded
                            : Icons.phone_outlined,
                        onTap: () => _toggleMethod(isMobile),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                AuthLinkRow(
                  prompt: "Don't have an account?",
                  action: 'Register',
                  onTap: () => AuthNavigator.toRegister(context),
                ),
                const SizedBox(height: 24),
                const AuthTermsText(),
              ],
            ),
          );
        },
      ),
    );
  }
}
