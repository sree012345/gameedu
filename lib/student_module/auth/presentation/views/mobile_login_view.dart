import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/constants/ui/image_assets.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';

import '../../bloc/auth_bloc.dart';
import '../../constants/auth_constants.dart';
import '../common/auth_common_widgets.dart';
import '../common/auth_server_error.dart';
import '../common/auth_navigator.dart';
import '../common/auth_password_field.dart';
import '../common/auth_scaffold.dart';
import '../common/auth_text_field.dart';

class MobileLoginView extends StatefulWidget {
  const MobileLoginView({super.key});

  @override
  State<MobileLoginView> createState() => _MobileLoginViewState();
}

class _MobileLoginViewState extends State<MobileLoginView> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Phone: OTP sent -> open OTP screen
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != c.status &&
              c.status == AuthStatus.otpSent &&
              c.flow == AuthFlow.login,
          listener: (context, state) => AuthNavigator.toOtp(context),
        ),
        // Email: password accepted -> next screen
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != c.status &&
              c.status == AuthStatus.authenticated &&
              c.flow == AuthFlow.login &&
              c.method == AuthMethod.email,
          listener: (context, state) => AuthNavigator.toHome(context),
        ),
        // One-shot messages (errors from Firebase, Google coming soon)
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) => c.message != null && p.message != c.message,
          listener: (context, state) => showAuthMessage(context, state.message!),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bloc = context.read<AuthBloc>();
          final isEmail = state.loginNeedsPassword;

          return AuthScaffold(
            showBack: Navigator.of(context).canPop(),
            hero: const AuthHeroImage(
              asset: ImageAssets.auth,
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
                  label: 'Email or Mobile Number',
                  hint: 'Enter email or mobile',
                  prefixIcon: Icons.mail_outline_rounded,
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction:
                      isEmail ? TextInputAction.next : TextInputAction.done,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      AuthConstants.identifierMaxLength,
                    ),
                  ],
                  errorText: state.loginIdentifierError,
                  onChanged: (v) => bloc.add(LoginIdentifierChanged(v)),
                  onSubmitted: (_) {
                    if (!isEmail) bloc.add(const LoginSubmitted());
                  },
                ),
                // Email typed -> ask for the password
                // (plain if, no animated resize -> no height exception)
                if (isEmail) ...[
                  const SizedBox(height: 14),
                  AuthPasswordField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    errorText: state.loginPasswordError,
                    onChanged: (v) => bloc.add(LoginPasswordChanged(v)),
                    onSubmitted: (_) => bloc.add(const LoginSubmitted()),
                  ),
                ],
                const SizedBox(height: 24),
                MediumButton(
                  text: isEmail ? 'Login' : 'Send OTP',
                  isLoading: state.isLoginLoading,
                  onPressed: () => bloc.add(const LoginSubmitted()),
                ),
                AuthServerError(message: state.loginServerError),
                const SizedBox(height: 26),
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
