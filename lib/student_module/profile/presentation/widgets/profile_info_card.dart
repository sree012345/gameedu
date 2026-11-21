import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

List<BoxShadow> profileCardShadow() => [
  BoxShadow(
    color: AppPalette.buttonShadowColor.withValues(alpha: 0.7),
    blurRadius: 14,
    offset: const Offset(0, 5),
  ),
];

/// White card with an icon + title and a list of rows.
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: profileCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppPalette.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppPalette.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.authTextPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppPalette.authDividerColor),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

/// icon | label | value
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value = '',
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Replaces the text value (e.g. the skill level chip).
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final empty = value.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppPalette.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppPalette.authTextSecondaryColor,
              ),
            ),
          ),
          Container(
            width: 1.5,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: AppPalette.authDividerColor,
          ),
          Expanded(
            flex: 6,
            child:
                valueWidget ??
                Text(
                  empty ? 'Not provided' : value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: empty ? FontWeight.w500 : FontWeight.w700,
                    color: empty
                        ? AppPalette.hintTextColor
                        : AppPalette.authTextPrimaryColor,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
