import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';

import '../../bloc/auth_bloc.dart';
import '../../constants/auth_constants.dart';
import '../common/auth_common_widgets.dart';
import '../common/auth_server_error.dart';
import '../common/auth_navigator.dart';
import '../common/auth_password_field.dart';
import '../common/auth_scaffold.dart';
import '../common/auth_text_field.dart';

class MobileRegisterView extends StatefulWidget {
  const MobileRegisterView({super.key});

  @override
  State<MobileRegisterView> createState() => _MobileRegisterViewState();
}

class _MobileRegisterViewState extends State<MobileRegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _collegeController.dispose();
    _studentIdController.dispose();
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
              c.flow == AuthFlow.register,

          listener: (context, state) => AuthNavigator.toOtp(context),
        ),
        // Email: account created -> next screen
    BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) {
    final shouldNavigate =
        previous.status != current.status &&
        current.status == AuthStatus.authenticated &&
        current.flow == AuthFlow.register &&
        current.method == AuthMethod.email;

    debugPrint(
      '🔍 [Register Listener] '
      'Status: ${previous.status} -> ${current.status}, '
      'Flow: ${current.flow}, '
      'Method: ${current.method}, '
      'Navigate: $shouldNavigate',
    );

    return shouldNavigate;
  },
  listener: (context, state) {
    debugPrint('✅ [Register Listener] Calling toHome()');

    AuthNavigator.toHome(context);
  },
),
        // One-shot messages (Firebase errors)
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) => c.message != null && p.message != c.message,
          listener: (context, state) => showAuthMessage(context, state.message!),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bloc = context.read<AuthBloc>();
          final isEmail = state.registerNeedsPassword;

          return AuthScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthTitle(
                  title: 'Create Your',
                  highlight: 'Account',
                  subtitle: 'Enter your details to get started',
                ),
                const SizedBox(height: 22),
                AuthTextField(
                  label: 'Full Name',
                  hint: 'Your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  maxLength: AuthConstants.nameMaxLength,
                  errorText: state.fullNameError,
                  onChanged: (v) => bloc.add(RegisterFullNameChanged(v)),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  label: 'Email or Mobile Number',
                  hint: 'Enter email or mobile',
                  prefixIcon: Icons.mail_outline_rounded,
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      AuthConstants.identifierMaxLength,
                    ),
                  ],
                  errorText: state.registerIdentifierError,
                  onChanged: (v) => bloc.add(RegisterIdentifierChanged(v)),
                ),
                // Email typed -> ask password + confirm
                // (plain if, no animated resize -> no height exception)
                if (isEmail) ...[
                  const SizedBox(height: 14),
                  AuthPasswordField(
                    label: 'Password',
                    hint: 'Create a password',
                    controller: _passwordController,
                    autofillHints: const [AutofillHints.newPassword],
                    errorText: state.registerPasswordError,
                    onChanged: (v) => bloc.add(RegisterPasswordChanged(v)),
                  ),
                  const SizedBox(height: 14),
                  AuthPasswordField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmController,
                    errorText: state.registerConfirmPasswordError,
                    onChanged: (v) =>
                        bloc.add(RegisterConfirmPasswordChanged(v)),
                  ),
                ],
                const SizedBox(height: 14),
                // College is now a normal text field
                AuthTextField(
                  label: 'College',
                  hint: 'Enter your college name',
                  prefixIcon: Icons.school_outlined,
                  controller: _collegeController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      AuthConstants.collegeMaxLength,
                    ),
                  ],
                  errorText: state.collegeError,
                  onChanged: (v) => bloc.add(RegisterCollegeChanged(v)),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  label: 'Student ID',
                  hint: 'Enter your student ID',
                  prefixIcon: Icons.assignment_outlined,
                  controller: _studentIdController,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-/]')),
                    LengthLimitingTextInputFormatter(
                      AuthConstants.studentIdMaxLength,
                    ),
                  ],
                  errorText: state.studentIdError,
                  onChanged: (v) => bloc.add(RegisterStudentIdChanged(v)),
                  onSubmitted: (_) => bloc.add(const RegisterSubmitted()),
                ),
                const SizedBox(height: 18),
                AuthTermsCheckbox(
                  value: state.termsAccepted,
                  errorText: state.termsError,
                  onChanged: (v) => bloc.add(RegisterTermsToggled(v)),
                ),
                const SizedBox(height: 20),
                MediumButton(
                  text: isEmail ? 'Create Account' : 'Send OTP',
                  isLoading: state.isRegisterLoading,
                  onPressed: () => bloc.add(const RegisterSubmitted()),
                ),
                AuthServerError(message: state.registerServerError),
                const SizedBox(height: 22),
                AuthLinkRow(
                  prompt: 'Already have an account?',
                  action: 'Login',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
