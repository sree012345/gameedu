import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

/// "Arun Kumar" -> "AK". Falls back to "U".
String profileInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'[\s._\-@]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'U';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// Round profile picture: new photo (memory) -> saved photo (network)
/// -> initials. Optional camera badge.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.photoUrl = '',
    this.photoBytes,
    this.size = 120,
    this.showCamera = true,
  });

  final String name;
  final String photoUrl;
  final Uint8List? photoBytes;
  final double size;
  final bool showCamera;

  @override
  Widget build(BuildContext context) {
    final initials = _Initials(text: profileInitials(name), size: size);

    Widget inner;
    if (photoBytes != null) {
      inner = Image.memory(photoBytes!, fit: BoxFit.cover);
    } else if (photoUrl.isNotEmpty) {
      inner = Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => initials,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : initials,
      );
    } else {
      inner = initials;
    }

    final badge = size * 0.3;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(size * 0.04),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.authCardSurfaceColor,
              border: Border.all(
                color: AppPalette.white.withValues(alpha: 0.9),
                width: 3,
              ),
            ),
            child: ClipOval(child: inner),
          ),
          if (showCamera)
            Positioned(
              right: 0,
              bottom: size * 0.04,
              child: Container(
                width: badge,
                height: badge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.primaryBlue,
                  border: Border.all(color: AppPalette.white, width: 3),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppPalette.white,
                  size: badge * 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.text, required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.buttonShadowColor,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          color: AppPalette.primaryBlueDark,
        ),
      ),
    );
  }
}
