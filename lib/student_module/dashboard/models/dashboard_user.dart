import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

/// Signed-in user shown in the drawer and the dashboard.
/// Built from Firestore (`fullName`, `college`...) with FirebaseAuth as fallback.
class DashboardUser extends Equatable {
  const DashboardUser({
    required this.uid,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.college = '',
    this.studentId = '',
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String college;
  final String studentId;

  static String _clean(Object? v) => (v ?? '').toString().trim();

  static String _firstNonEmpty(List<String> values) =>
      values.firstWhere((v) => v.isNotEmpty, orElse: () => '');

  factory DashboardUser.fromSources(User user, Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};
    return DashboardUser(
      uid: user.uid,
      fullName: _firstNonEmpty([_clean(d['fullName']), _clean(user.displayName)]),
      email: _firstNonEmpty([_clean(d['email']), _clean(user.email)]),
      phone: _firstNonEmpty([_clean(d['phone']), _clean(user.phoneNumber)]),
      college: _clean(d['college']),
      studentId: _clean(d['studentId']),
    );
  }

  /// Full name -> email prefix -> phone -> "Student".
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (email.isNotEmpty) return email.split('@').first;
    if (phone.isNotEmpty) return phone;
    return 'Student';
  }

  String get firstName => displayName.split(RegExp(r'\s+')).first;

  /// Email, or phone when the user signed up with a number.
  String get contactLine => email.isNotEmpty ? email : phone;

  /// "Arun Kumar" -> "AK". Falls back to "U" for phone-only users.
  String get initials {
    final source = fullName.isNotEmpty
        ? fullName
        : (email.isNotEmpty ? email.split('@').first : '');
    final parts = source
        .split(RegExp(r'[\s._\-]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [uid, fullName, email, phone, college, studentId];
}
