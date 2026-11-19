import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.fullName,
    required this.college,
    required this.studentId,
    this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String fullName;
  final String college;
  final String studentId;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return UserModel(
      uid: uid,
      fullName: (map['fullName'] as String?) ?? '',
      college: (map['college'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      createdAt: toDate(map['createdAt']),
      updatedAt: toDate(map['updatedAt']),
    );
  }

  /// Used when writing. Timestamps are set by the service (server time).
  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'college': college,
    'studentId': studentId,
    'email': email,
    'phone': phone,
  };

  UserModel copyWith({
    String? fullName,
    String? college,
    String? studentId,
    String? email,
    String? phone,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      college: college ?? this.college,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}