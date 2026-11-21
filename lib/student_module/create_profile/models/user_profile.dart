import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

enum Gender {
  male('male', 'Male'),
  female('female', 'Female'),
  other('other', 'Other'),
  preferNotToSay('prefer_not_to_say', 'Prefer not to say');

  const Gender(this.value, this.label);

  final String value;
  final String label;

  static Gender? fromValue(String? value) {
    for (final g in Gender.values) {
      if (g.value == value) return g;
    }
    return null;
  }
}

enum SkillLevel {
  beginner('beginner', 'Beginner'),
  intermediate('intermediate', 'Intermediate'),
  advanced('advanced', 'Advanced');

  const SkillLevel(this.value, this.label);

  final String value;
  final String label;

  static SkillLevel fromValue(String? value) {
    for (final s in SkillLevel.values) {
      if (s.value == value) return s;
    }
    return SkillLevel.beginner;
  }
}

/// Photo chosen from the gallery (kept in memory until Finish).
/// Compared by identity on purpose, so big byte lists are never diffed.
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// User document (`${env}_users/{uid}`) fields used by Create Profile.
class UserProfile extends Equatable {
  const UserProfile({
    this.uid = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.photoUrl = '',
    this.gender,
    this.college = '',
    this.department = '',
    this.yearOfStudy,
    this.studentId = '',
    this.interests = const [],
    this.skillLevel = SkillLevel.beginner,
    this.onboardingCompleted = false,
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String photoUrl;
  final Gender? gender;
  final String college;
  final String department;
  final int? yearOfStudy;
  final String studentId;
  final List<String> interests;
  final SkillLevel skillLevel;
  final bool onboardingCompleted;

  static String _s(Object? v) => (v ?? '').toString().trim();

  /// Firestore data first, FirebaseAuth as fallback (name, email, phone).
  factory UserProfile.fromSources(User user, Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};
    final year = d['yearOfStudy'];

    return UserProfile(
      uid: user.uid,
      fullName: _s(d['fullName']).isNotEmpty
          ? _s(d['fullName'])
          : _s(user.displayName),
      email: _s(d['email']).isNotEmpty ? _s(d['email']) : _s(user.email),
      phone: _s(d['phone']).isNotEmpty ? _s(d['phone']) : _s(user.phoneNumber),
      photoUrl: _s(d['photoUrl']),
      gender: Gender.fromValue(d['gender'] as String?),
      college: _s(d['college']),
      department: _s(d['department']),
      yearOfStudy: year is num ? year.toInt() : null,
      studentId: _s(d['studentId']),
      interests:
          (d['interests'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      skillLevel: SkillLevel.fromValue(d['skillLevel'] as String?),
      onboardingCompleted: d['onboardingCompleted'] == true,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    phone,
    photoUrl,
    gender,
    college,
    department,
    yearOfStudy,
    studentId,
    interests,
    skillLevel,
    onboardingCompleted,
  ];
}
