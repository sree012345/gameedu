import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';

import '../../bloc/auth_bloc.dart';
import '../../constants/auth_constants.dart';
import '../common/auth_common_widgets.dart';
import '../common/auth_navigator.dart';
import '../common/auth_scaffold.dart';
import '../common/auth_text_field.dart';
import '../common/college_picker_sheet.dart';

class MobileRegisterView extends StatefulWidget {
  const MobileRegisterView({super.key});

  @override
  State<MobileRegisterView> createState() => _MobileRegisterViewState();
}

class _MobileRegisterViewState extends State<MobileRegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _collegeController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _pickCollege() async {
    FocusScope.of(context).unfocus();
    final bloc = context.read<AuthBloc>();

    final selected = await showCollegePickerSheet(
      context,
      selected: bloc.state.college,
    );
    if (selected != null) {
      bloc.add(RegisterCollegeSelected(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // OTP sent from the Register form -> open OTP screen
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != c.status &&
              c.status == AuthStatus.otpSent &&
              c.flow == AuthFlow.register,
          listener: (context, state) => AuthNavigator.toOtp(context),
        ),
        // Keep the read-only college field in sync with the bloc
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) => p.college != c.college,
          listener: (context, state) => _collegeController.text = state.college,
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bloc = context.read<AuthBloc>();
          final hasCollege = state.college.isNotEmpty;

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
                  errorText: state.registerIdentifierError,
                  onChanged: (v) => bloc.add(RegisterIdentifierChanged(v)),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  label: 'College',
                  hint: 'Select your college',
                  prefixIcon: Icons.school_outlined,
                  controller: _collegeController,
                  readOnly: true,
                  onTap: _pickCollege,
                  suffixIcon: hasCollege
                      ? Icons.check_circle_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  suffixIconColor: hasCollege
                      ? AppPalette.successColor
                      : AppPalette.authTextSecondaryColor,
                  errorText: state.collegeError,
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
                  text: 'Continue',
                  isLoading: state.isRegisterLoading,
                  onPressed: () => bloc.add(const RegisterSubmitted()),
                ),
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
