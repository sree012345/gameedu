import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/init_dependencies.dart'; // exports serviceLocator
import 'package:game_edu/student_module/create_profile/constants/profile_constants.dart';
import 'package:game_edu/student_module/create_profile/models/user_profile.dart';
import 'package:game_edu/student_module/create_profile/presentation/widgets/profile_widgets.dart'
    show ProfileChoicePill, ProfileErrorText, ProfileLabel;
import 'package:image_picker/image_picker.dart';

import '../bloc/edit_profile_bloc.dart';
import 'widgets/edit_fields.dart';
import 'widgets/profile_action_button.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_formatters.dart';
import 'widgets/profile_headers.dart';

/// "Edit Profile": photo, name, gender, college, department and year.
/// Email / mobile are read-only when saved, and can be ADDED when missing.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditProfileBloc>(
      create: (_) =>
          serviceLocator<EditProfileBloc>()..add(const EditProfileStarted()),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _collegeController = TextEditingController();
  final _departmentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _collegeController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  /// Pre-fill once the data is loaded. Email / phone stay empty when the
  /// user has none (they type it).
  void _prefill(EditProfileState s) {
    _nameController.text = s.fullName;
    _emailController.text = s.email;
    _phoneController.text = formatPhone(s.phone);
    _collegeController.text = s.college;
    _departmentController.text = s.department;
  }

  Future<void> _pickPhoto() async {
    final bloc = context.read<EditProfileBloc>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      bloc.add(EditPhotoSelected(PickedPhoto(bytes: bytes, fileName: file.name)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not open your photos'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPalette.authTextPrimaryColor,
        ),
      );
    }
  }

  Future<void> _pickYear(EditProfileState state) async {
    final bloc = context.read<EditProfileBloc>();
    FocusScope.of(context).unfocus();

    final year = await showProfileOptionSheet<int>(
      context,
      title: 'Year of Study',
      options: [for (final y in ProfileConstants.years) (yearLabel(y), y)],
      selected: state.yearOfStudy,
    );
    if (year != null) bloc.add(EditYearSelected(year));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditProfileBloc, EditProfileState>(
          listenWhen: (p, c) =>
              p.status == EditProfileStatus.loading &&
              c.status != EditProfileStatus.loading,
          listener: (context, state) => _prefill(state),
        ),
        // Saved -> back to My Profile (it refreshes itself)
        BlocListener<EditProfileBloc, EditProfileState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == EditProfileStatus.saved,
          listener: (context, state) => Navigator.of(context).pop(true),
        ),
      ],
      child: BlocBuilder<EditProfileBloc, EditProfileState>(
        builder: (context, state) {
          final bloc = context.read<EditProfileBloc>();

          return Scaffold(
            backgroundColor: AppPalette.infoSurfaceColor,
            bottomNavigationBar: state.isLoading
                ? null
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.serverError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                state.serverError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.errorText,
                                ),
                              ),
                            ),
                          ProfileActionButton(
                            text: 'Save Changes',
                            icon: Icons.arrow_forward_rounded,
                            loading: state.isSaving,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              bloc.add(const EditSavePressed());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
            body: Column(
              children: [
                EditProfileHeader(
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            child: _Form(
                              state: state,
                              nameController: _nameController,
                              emailController: _emailController,
                              phoneController: _phoneController,
                              collegeController: _collegeController,
                              departmentController: _departmentController,
                              onPickPhoto: _pickPhoto,
                              onPickYear: () => _pickYear(state),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.state,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.collegeController,
    required this.departmentController,
    required this.onPickPhoto,
    required this.onPickYear,
  });

  final EditProfileState state;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController collegeController;
  final TextEditingController departmentController;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickYear;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EditProfileBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── photo ──
        Center(
          child: GestureDetector(
            onTap: onPickPhoto,
            child: ProfileAvatar(
              name: state.fullName.isNotEmpty ? state.fullName : state.email,
              photoUrl: state.photoUrl,
              photoBytes: state.photo?.bytes,
              size: 128,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: InkWell(
            onTap: onPickPhoto,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.primaryBlue,
                ),
              ),
            ),
          ),
        ),
        const Center(
          child: Text(
            'JPG or PNG, up to 5 MB',
            style: TextStyle(
              fontSize: 13,
              color: AppPalette.authTextSecondaryColor,
            ),
          ),
        ),
        if (state.photoError != null)
          Center(child: ProfileErrorText(state.photoError!, center: true)),
        const SizedBox(height: 20),

        // ── basic ──
        EditTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          prefixIcon: Icons.person_outline_rounded,
          controller: nameController,
          textInputAction: TextInputAction.next,
          maxLength: ProfileConstants.nameMaxLength,
          errorText: state.fullNameError,
          onChanged: (v) => bloc.add(EditFullNameChanged(v)),
        ),
        const SizedBox(height: 16),

        // Email: saved -> read-only, missing -> can be added
        EditTextField(
          label: 'Email',
          hint: 'Add your email',
          prefixIcon: Icons.mail_outline_rounded,
          controller: emailController,
          readOnly: !state.canAddEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          inputFormatters: [LengthLimitingTextInputFormatter(254)],
          errorText: state.emailError,
          helperText: state.canAddEmail
              ? 'Optional. Once added it cannot be changed here.'
              : null,
          onChanged: state.canAddEmail
              ? (v) => bloc.add(EditEmailChanged(v))
              : null,
        ),
        const SizedBox(height: 16),

        // Mobile: saved -> read-only, missing -> can be added
        EditTextField(
          label: 'Mobile Number',
          hint: 'Add your 10-digit mobile number',
          prefixIcon: Icons.phone_outlined,
          controller: phoneController,
          readOnly: !state.canAddPhone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          errorText: state.phoneError,
          helperText: state.canAddPhone
              ? 'Optional. Once added it cannot be changed here.'
              : null,
          onChanged: state.canAddPhone
              ? (v) => bloc.add(EditPhoneChanged(v))
              : null,
        ),
        const SizedBox(height: 16),

        // ── gender ──
        const ProfileLabel('Gender'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final g in Gender.values)
              ProfileChoicePill(
                label: g.label,
                selected: state.gender == g,
                onTap: () => bloc.add(EditGenderSelected(g)),
              ),
          ],
        ),
        if (state.genderError != null) ProfileErrorText(state.genderError!),
        const SizedBox(height: 16),

        // ── education ──
        EditTextField(
          label: 'College',
          hint: 'Enter your college name',
          prefixIcon: Icons.school_outlined,
          controller: collegeController,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ProfileConstants.collegeMaxLength),
          ],
          errorText: state.collegeError,
          onChanged: (v) => bloc.add(EditCollegeChanged(v)),
        ),
        const SizedBox(height: 16),
        EditTextField(
          label: 'Department',
          hint: 'e.g. Computer Science',
          prefixIcon: Icons.layers_outlined,
          controller: departmentController,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ProfileConstants.departmentMaxLength),
          ],
          errorText: state.departmentError,
          onChanged: (v) => bloc.add(EditDepartmentChanged(v)),
        ),
        const SizedBox(height: 16),
        ProfileSelectField(
          label: 'Year of Study',
          hint: 'Select your year',
          prefixIcon: Icons.calendar_month_outlined,
          valueLabel: yearLabel(state.yearOfStudy),
          errorText: state.yearError,
          onTap: onPickYear,
        ),
      ],
    );
  }
}
