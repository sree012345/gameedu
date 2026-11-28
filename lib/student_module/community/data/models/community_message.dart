import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum CommunityMessageType {
  text,
  image,
  video,
  audio;

  static CommunityMessageType parse(String? value) {
    return CommunityMessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CommunityMessageType.text,
    );
  }

  bool get isMedia => this != CommunityMessageType.text;
}

class CommunityMessage extends Equatable {
  const CommunityMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderIsAdmin,
    required this.type,
    required this.createdAt,
    this.text,
    this.mediaUrl,
    this.fileName,
    this.isDeleted = false,
  });

  final String id;
  final String senderId;
  final String senderName;
  final bool senderIsAdmin;
  final CommunityMessageType type;
  final String? text;
  final String? mediaUrl;
  final String? fileName;
  final DateTime createdAt;
  final bool isDeleted;

  factory CommunityMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return CommunityMessage(
      id: doc.id,
      senderId: d['senderId'] as String? ?? '',
      senderName: d['senderName'] as String? ?? 'User',
      senderIsAdmin: d['senderIsAdmin'] as bool? ?? false,
      type: CommunityMessageType.parse(d['type'] as String?),
      text: d['text'] as String?,
      mediaUrl: d['mediaUrl'] as String?,
      fileName: d['fileName'] as String?,
      // A just-written message has a pending server timestamp (null locally).
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: d['isDeleted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderIsAdmin,
        type,
        text,
        mediaUrl,
        fileName,
        createdAt,
        isDeleted,
      ];
}
