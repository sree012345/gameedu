import 'package:flutter/material.dart';

class ProfileInterest {
  const ProfileInterest(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;
}

class ProfileConstants {
  ProfileConstants._();

  static const int stepCount = 3;

  static const int nameMinLength = 2;
  static const int nameMaxLength = 50;
  static const int collegeMinLength = 3;
  static const int collegeMaxLength = 100;
  static const int departmentMinLength = 2;
  static const int departmentMaxLength = 60;
  static const int studentIdMinLength = 4;
  static const int studentIdMaxLength = 20;

  static const int minInterests = 3;

  /// JPG / PNG, up to 5 MB.
  static const int maxPhotoBytes = 5 * 1024 * 1024;

  static const List<int> years = [1, 2, 3, 4];

  static const List<ProfileInterest> interests = [
    ProfileInterest('unity', 'Unity', Icons.sports_esports_outlined),
    ProfileInterest('unreal_engine', 'Unreal Engine', Icons.videocam_outlined),
    ProfileInterest('pixel_art_2d', '2D Pixel Art', Icons.image_outlined),
    ProfileInterest('modeling_3d', '3D Modeling', Icons.workspace_premium_outlined),
    ProfileInterest('game_design', 'Game Design', Icons.flag_outlined),
    ProfileInterest('game_audio', 'Game Audio', Icons.notifications_none_rounded),
    ProfileInterest('csharp_coding', 'C# Coding', Icons.code_rounded),
    ProfileInterest('level_design', 'Level Design', Icons.location_on_outlined),
  ];
}
