import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';

import '../../bloc/create_profile_bloc.dart';
import '../../constants/profile_constants.dart';
import '../../models/user_profile.dart';
import '../widgets/profile_widgets.dart';

class InterestsStep extends StatelessWidget {
  const InterestsStep({super.key, required this.state});

  final CreateProfileState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CreateProfileBloc>();
    const items = ProfileConstants.interests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileTitle(
          title: 'Pick your interests',
          subtitle: 'Choose at least ${ProfileConstants.minInterests} to personalise your courses',
        ),
        const SizedBox(height: 18),
        // Two cards per row (fixed card height -> no overflow)
        for (int i = 0; i < items.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InterestCard(
                  interest: items[i],
                  selected: state.interests.contains(items[i].id),
                  onTap: () => bloc.add(ProfileInterestToggled(items[i].id)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < items.length
                    ? _InterestCard(
                        interest: items[i + 1],
                        selected: state.interests.contains(items[i + 1].id),
                        onTap: () =>
                            bloc.add(ProfileInterestToggled(items[i + 1].id)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
        if (state.interestsError != null)
          ProfileErrorText(state.interestsError!),
        const SizedBox(height: 24),
        const Text(
          'Your skill level',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppPalette.authTextPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        _SkillSelector(
          selected: state.skillLevel,
          onChanged: (level) => bloc.add(ProfileSkillLevelSelected(level)),
        ),
      ],
    );
  }
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({
    required this.interest,
    required this.selected,
    required this.onTap,
  });

  final ProfileInterest interest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(22);

    return Material(
      color: selected
          ? AppPalette.primaryBlue.withValues(alpha: 0.07)
          : AppPalette.authCardSurfaceColor,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: selected
                  ? AppPalette.primaryBlue
                  : AppPalette.inputBorderColor.withValues(alpha: 0.7),
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                // Fixed padding so the icon never shifts when selected.
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppPalette.primaryBlue
                            : AppPalette.primaryBlue.withValues(alpha: 0.10),
                      ),
                      child: Icon(
                        interest.icon,
                        size: 22,
                        color: selected
                            ? AppPalette.white
                            : AppPalette.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        // Keep text clear of the checkmark badge when selected.
                        padding:
                            EdgeInsetsDirectional.only(end: selected ? 18 : 0),
                        child: Text(
                          interest.label,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.authTextPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppPalette.primaryBlue,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: AppPalette.white,
                      ),
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

class _SkillSelector extends StatelessWidget {
  const _SkillSelector({required this.selected, required this.onChanged});

  final SkillLevel selected;
  final ValueChanged<SkillLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppPalette.inputBorderColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          for (final level in SkillLevel.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: level == selected
                        ? AppPalette.authCardSurfaceColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: level == selected
                        ? [
                            BoxShadow(
                              color: AppPalette.buttonShadowColor
                                  .withValues(alpha: 0.9),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      level.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: level == selected
                            ? AppPalette.primaryBlue
                            : AppPalette.authTextSecondaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}