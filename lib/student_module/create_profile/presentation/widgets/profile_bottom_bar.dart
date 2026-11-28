import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';
import '../../bloc/create_profile_bloc.dart';
/// White rounded bottom bar: [Back] [Continue / Finish Setup] + red server error.
class ProfileBottomBar extends StatelessWidget {
  const ProfileBottomBar({
    super.key,
    required this.state,
    required this.onBack,
    required this.onNext,
  });

  final CreateProfileState state;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppPalette.inputBorderColor.withValues(alpha: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                
                  Expanded(
                    flex: 5,
                    child: MediumButton(
                      text: state.isLastStep ? 'Finish Setup' : 'Continue',
                      isLoading: state.isSaving,
                      onPressed: onNext,
                    ),
                  ),
                ],
              ),
              if (state.serverError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
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
            ],
          ),
        ),
      ),
    );
  }
}


