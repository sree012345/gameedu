import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/init_dependencies.dart'; // exports serviceLocator

import '../bloc/create_profile_bloc.dart';
import 'steps/basic_details_step.dart';
import 'steps/college_details_step.dart';
import 'steps/interests_step.dart';
import 'widgets/profile_bottom_bar.dart';
import 'widgets/profile_header.dart';

/// Create Profile (3 steps). Name + college come pre-filled from Firebase.
class CreateProfilePage extends StatelessWidget {
  const CreateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateProfileBloc>(
      create: (_) =>
          serviceLocator<CreateProfileBloc>()..add(const CreateProfileStarted()),
      child: const _CreateProfileView(),
    );
  }
}

class _CreateProfileView extends StatefulWidget {
  const _CreateProfileView();

  @override
  State<_CreateProfileView> createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<_CreateProfileView> {
  // Controllers live here so the text survives Back / Continue.
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _studentIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  /// Pre-fill the fields once the data is loaded.
  void _prefill(CreateProfileState s) {
    _nameController.text = s.fullName;
    _collegeController.text = s.college;
    _departmentController.text = s.department;
    _studentIdController.text = s.studentId;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateProfileBloc, CreateProfileState>(
          listenWhen: (p, c) =>
              p.status == CreateProfileStatus.loading &&
              c.status != CreateProfileStatus.loading,
          listener: (context, state) => _prefill(state),
        ),
        // Finished (or skipped) -> dashboard
        BlocListener<CreateProfileBloc, CreateProfileState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == CreateProfileStatus.completed,
          listener: (context, state) => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(RouterPath.home, (route) => false),
        ),
      ],
      child: BlocBuilder<CreateProfileBloc, CreateProfileState>(
        builder: (context, state) {
          final bloc = context.read<CreateProfileBloc>();

          return PopScope(
            // Back goes to the previous step; first step can't be left.
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) bloc.add(const ProfileBackPressed());
            },
            child: Scaffold(
              backgroundColor: AppPalette.infoSurfaceColor,
              bottomNavigationBar: state.isLoading
                  ? null
                  : ProfileBottomBar(
                      state: state,
                      onBack: () => bloc.add(const ProfileBackPressed()),
                      onNext: () {
                        FocusScope.of(context).unfocus();
                        bloc.add(const ProfileNextPressed());
                      },
                    ),
              body: Column(
                children: [
                  ProfileHeader(
                    showBack: state.step > 0,
                    skipEnabled: !state.isSaving && !state.isLoading,
                    onBack: () => bloc.add(const ProfileBackPressed()),
                    onSkip: () => bloc.add(const ProfileSkipPressed()),
                  ),
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProfileStepIndicator(step: state.step),
                                  const SizedBox(height: 22),
                                  switch (state.step) {
                                    0 => BasicDetailsStep(
                                      state: state,
                                      nameController: _nameController,
                                    ),
                                    1 => CollegeDetailsStep(
                                      state: state,
                                      collegeController: _collegeController,
                                      departmentController: _departmentController,
                                      studentIdController: _studentIdController,
                                    ),
                                    _ => InterestsStep(state: state),
                                  },
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
}
