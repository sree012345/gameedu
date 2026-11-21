import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/init_dependencies.dart'; // exports serviceLocator

import '../bloc/my_profile_bloc.dart';
import 'widgets/profile_formatters.dart';
import 'widgets/profile_headers.dart';
import 'widgets/profile_info_card.dart';

/// "My Profile": photo, email, personal and educational details.
class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyProfileBloc>(
      create: (_) =>
          serviceLocator<MyProfileBloc>()..add(const MyProfileStarted()),
      child: const _MyProfileView(),
    );
  }
}

class _MyProfileView extends StatelessWidget {
  const _MyProfileView();

  Future<void> _edit(BuildContext context) async {
    final bloc = context.read<MyProfileBloc>();
    final messenger = ScaffoldMessenger.of(context);

    // Edit screen pops `true` after a successful save.
    final result = await Navigator.of(context).pushNamed(RouterPath.editProfile);

    if (result == true) {
      bloc.add(const MyProfileRefreshed());
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPalette.authTextPrimaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyProfileBloc, MyProfileState>(
      builder: (context, state) {
        final profile = state.profile;

        return Scaffold(
          backgroundColor: AppPalette.infoSurfaceColor,
          // No bottom "Edit Profile" button anymore.
          body: SafeArea(
            child: Column(
              children: [
                MyProfileHeader(
                  profile: profile,
                  onAvatarTap: () {
                    if (profile != null) _edit(context);
                  },
                ),
                Expanded(
                  child: _Body(
                    state: state,
                    onEdit: () => _edit(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onEdit});

  final MyProfileState state;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (state.status == MyProfileStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = state.profile;
    if (state.status == MyProfileStatus.failure || profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: AppPalette.authTextSecondaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                state.error ?? 'Could not load your profile',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppPalette.errorText,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.read<MyProfileBloc>().add(
                  const MyProfileStarted(),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          // Personal Information card with the pencil on the right side
          Stack(
            children: [
              ProfileInfoCard(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                children: [
                  ProfileInfoRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: profile.email,
                  ),
                  ProfileInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Mobile Number',
                    value: formatPhone(profile.phone),
                  ),
                  ProfileInfoRow(
                    icon: Icons.wc_rounded,
                    label: 'Gender',
                    value: profile.gender?.label ?? '',
                  ),
                ],
              ),
              Positioned(
                top: 6,
                right: 8,
                child: IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit Profile',
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppPalette.primaryBlue,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          ProfileInfoCard(
            icon: Icons.school_outlined,
            title: 'Educational Information',
            children: [
              ProfileInfoRow(
                icon: Icons.account_balance_outlined,
                label: 'College',
                value: profile.college,
              ),
              ProfileInfoRow(
                icon: Icons.layers_outlined,
                label: 'Department',
                value: profile.department,
              ),
              ProfileInfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Year of Study',
                value: yearLabel(profile.yearOfStudy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}