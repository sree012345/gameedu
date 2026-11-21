import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

/// Full-width gradient button with an icon (Edit Profile / Save Changes).
class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;

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
              height: 58,
              width: double.infinity,
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
                          if (icon == Icons.edit_outlined) ...[
                            Icon(icon, color: AppPalette.white, size: 22),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.white,
                            ),
                          ),
                          if (icon != Icons.edit_outlined) ...[
                            const SizedBox(width: 10),
                            Icon(icon, color: AppPalette.white, size: 22),
                          ],
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
