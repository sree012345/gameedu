import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/create_profile_bloc.dart';
import '../../constants/profile_constants.dart';
import '../widgets/profile_widgets.dart';

class CollegeDetailsStep extends StatelessWidget {
  const CollegeDetailsStep({
    super.key,
    required this.state,
    required this.collegeController,
    required this.departmentController,
    required this.studentIdController,
  });

  final CreateProfileState state;
  final TextEditingController collegeController;
  final TextEditingController departmentController;
  final TextEditingController studentIdController;

  static String _yearLabel(int y) => switch (y) {
    1 => '1st Year',
    2 => '2nd Year',
    3 => '3rd Year',
    _ => '${y}th Year',
  };

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CreateProfileBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileTitle(
          title: 'Your college details',
          subtitle: 'Confirm your college and student details',
        ),
        const SizedBox(height: 20),
        ProfileTextField(
          label: 'College',
          hint: 'Enter your college name',
          prefixIcon: Icons.school_outlined,
          controller: collegeController,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ProfileConstants.collegeMaxLength),
          ],
          errorText: state.collegeError,
          onChanged: (v) => bloc.add(ProfileCollegeChanged(v)),
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: 'Department',
          hint: 'e.g. Computer Science & Engg.',
          prefixIcon: Icons.menu_book_outlined,
          controller: departmentController,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ProfileConstants.departmentMaxLength),
          ],
          errorText: state.departmentError,
          onChanged: (v) => bloc.add(ProfileDepartmentChanged(v)),
        ),
        const SizedBox(height: 16),
        const ProfileLabel('Year of Study'),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int i = 0; i < ProfileConstants.years.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: ProfileChoicePill(
                  label: _yearLabel(ProfileConstants.years[i]),
                  selected: state.yearOfStudy == ProfileConstants.years[i],
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  onTap: () =>
                      bloc.add(ProfileYearSelected(ProfileConstants.years[i])),
                ),
              ),
            ],
          ],
        ),
        if (state.yearError != null) ProfileErrorText(state.yearError!),
        const SizedBox(height: 16),
        ProfileTextField(
          label: 'Student ID',
          hint: 'Enter your student ID',
          prefixIcon: Icons.assignment_outlined,
          controller: studentIdController,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-/]')),
            LengthLimitingTextInputFormatter(ProfileConstants.studentIdMaxLength),
          ],
          errorText: state.studentIdError,
          onChanged: (v) => bloc.add(ProfileStudentIdChanged(v)),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }
}
