import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'community_message.dart';

class CommunityModel extends Equatable {
  const CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    this.imageUrl,
    this.participantIds = const [],
    this.participantsCanMessage = false,
    this.lastMessagePreview,
    this.lastMessageType,
    this.lastMessageAt,
    this.createdAt,
    this.unreadCounts = const {},
    this.clearedAt = const {},
  });

  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  /// The admin who created the community. Never part of [participantIds].
  final String adminId;
  final List<String> participantIds;

  /// When false (default) only the admin can send messages.
  final bool participantsCanMessage;

  final String? lastMessagePreview;
  final CommunityMessageType? lastMessageType;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  /// uid -> number of unread messages (maintained by the Cloud Function).
  final Map<String, int> unreadCounts;

  /// uid -> time that user cleared the chat (older messages are hidden
  /// for that user only).
  final Map<String, DateTime> clearedAt;

  int get memberCount => participantIds.length + 1; // + admin

  DateTime get sortTime =>
      lastMessageAt ?? createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  bool isAdmin(String uid) => adminId == uid;

  bool isMember(String uid) => adminId == uid || participantIds.contains(uid);

  bool canSend(String uid) =>
      isAdmin(uid) || (participantsCanMessage && participantIds.contains(uid));

  int unreadFor(String uid) => unreadCounts[uid] ?? 0;

  DateTime? clearedAtFor(String uid) => clearedAt[uid];

  /// True when this user cleared the chat after the last message was sent,
  /// so the list must not show that (hidden) last message.
  bool isChatClearedFor(String uid) {
    final cleared = clearedAt[uid];
    if (cleared == null || lastMessageAt == null) return false;
    return !lastMessageAt!.isAfter(cleared);
  }

  factory CommunityModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};

    final unread = <String, int>{};
    final rawUnread = d['unreadCounts'];
    if (rawUnread is Map) {
      rawUnread.forEach((key, value) {
        if (value is num) unread[key.toString()] = value.toInt();
      });
    }

    final cleared = <String, DateTime>{};
    final rawCleared = d['clearedAt'];
    if (rawCleared is Map) {
      rawCleared.forEach((key, value) {
        if (value is Timestamp) cleared[key.toString()] = value.toDate();
      });
    }

    final rawType = d['lastMessageType'] as String?;

    return CommunityModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      description: d['description'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      adminId: d['adminId'] as String? ?? '',
      participantIds: List<String>.from((d['participantIds'] as List?) ?? const []),
      participantsCanMessage: d['participantsCanMessage'] as bool? ?? false,
      lastMessagePreview: d['lastMessagePreview'] as String?,
      lastMessageType:
          rawType == null ? null : CommunityMessageType.parse(rawType),
      lastMessageAt: (d['lastMessageAt'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      unreadCounts: unread,
      clearedAt: cleared,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        adminId,
        participantIds,
        participantsCanMessage,
        lastMessagePreview,
        lastMessageType,
        lastMessageAt,
        createdAt,
        unreadCounts,
        clearedAt,
      ];
}