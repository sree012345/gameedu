import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

import '../../bloc/create_profile_bloc.dart';
import '../../constants/profile_constants.dart';

/// Blue top bar with a centered title and an optional back button.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.showBack,
    required this.onBack,
    required this.onSkip,
    this.skipEnabled = true,
  });

  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final bool skipEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.headerGradientStart, AppPalette.headerGradientMid],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: showBack
                    ? Material(
                        color: AppPalette.overlayWhite20,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onBack,
                          child: const SizedBox(
                            width: 42,
                            height: 42,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppPalette.white,
                              size: 22,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              const Expanded(
                child: Text(
                  'Create Profile',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.white,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Step 1 of 3 ........ Basic Details" + 3 progress bars.
class ProfileStepIndicator extends StatelessWidget {
  const ProfileStepIndicator({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Step ${step + 1} of ${ProfileConstants.stepCount}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppPalette.primaryBlue,
              ),
            ),
            const Spacer(),
            Text(
              CreateProfileState.stepTitles[step],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppPalette.authTextSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int i = 0; i < ProfileConstants.stepCount; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= step
                        ? AppPalette.primaryBlue
                        : AppPalette.inputBorderColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}