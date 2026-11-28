import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../community_theme.dart';

/// Rounded-square avatar of a community (same shape as the Chat list icons).
class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({
    super.key,
    required this.imageUrl,
    this.size = 58,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.3);
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: communityGradient, borderRadius: radius),
      child: Icon(Icons.groups_rounded, color: Colors.white, size: size * 0.5),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}

/// Circular avatar of a user (initial letter fallback).
class CommunityUserAvatar extends StatelessWidget {
  const CommunityUserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 22,
  });

  final String name;
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final url = photoUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: CommunityColors.primary.withOpacity(0.12),
      backgroundImage:
          (url == null || url.isEmpty) ? null : CachedNetworkImageProvider(url),
      child: (url == null || url.isEmpty)
          ? Text(
              initial,
              style: TextStyle(
                color: CommunityColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
