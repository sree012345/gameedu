import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

import '../../../create_profile/models/user_profile.dart';
import 'profile_avatar.dart';
import 'profile_formatters.dart';

const LinearGradient _headerGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppPalette.headerGradientStart, AppPalette.headerGradientMid],
);

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.overlayWhite20,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.arrow_back_rounded, color: AppPalette.white, size: 22),
        ),
      ),
    );
  }
}

/// "My Profile" header: avatar, name, email and the "Student" chip.
/// No back button, title, blue gradient or wave.
class MyProfileHeader extends StatelessWidget {
  const MyProfileHeader({
    super.key,
    required this.profile,
    required this.onAvatarTap,
  });

  final UserProfile? profile;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final name = profile == null || profile!.fullName.isEmpty
        ? (profile?.email.isNotEmpty ?? false
              ? profile!.email.split('@').first
              : 'Student')
        : profile!.fullName;
    final contact = profile == null
        ? ''
        : (profile!.email.isNotEmpty ? profile!.email : formatPhone(profile!.phone));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: ProfileAvatar(
              name: name,
              photoUrl: profile?.photoUrl ?? '',
              size: 112,
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 1.5,
            height: 90,
            color: AppPalette.authTextSecondaryColor.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.authTextPrimaryColor,
                  ),
                ),
                if (contact.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        profile!.email.isNotEmpty
                            ? Icons.mail_outline_rounded
                            : Icons.phone_outlined,
                        size: 18,
                        color: AppPalette.authTextSecondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          contact,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppPalette.authTextSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.primaryBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 18,
                        color: AppPalette.primaryBlue,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Student',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Edit Profile" header: back + title, rounded bottom.
class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: _headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          child: Row(
            children: [
              _BackButton(onTap: onBack),
              const Expanded(
                child: Text(
                  'Edit Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.white,
                  ),
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
        ),
      ),
    );
  }
}