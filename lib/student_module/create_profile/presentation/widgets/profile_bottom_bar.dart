import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
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
                    child: _PrimaryButton(
                      text: state.isLastStep ? 'Finish Setup' : 'Continue',
                      loading: state.isSaving,
                      onTap: onNext,
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.loading,
    required this.onTap,
  });

  final String text;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppPalette.primaryButtonGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: AppPalette.buttonShadowColor, offset: Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: loading ? null : onTap,
            child: SizedBox(
              height: 56,
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppPalette.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            text,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppPalette.white,
                            size: 22,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
