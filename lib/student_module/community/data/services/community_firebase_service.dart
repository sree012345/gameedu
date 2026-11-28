import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../community_config.dart';
import '../community_exception.dart';
import '../models/community_message.dart';
import '../models/community_model.dart';
import '../models/community_user.dart';

/// Thin wrapper over Firestore / Storage / Auth. No business rules here.
class CommunityFirebaseService {
  CommunityFirebaseService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
    Future<CommunityUser> Function()? currentUserLoader,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _currentUserLoader = currentUserLoader;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  /// Optional hook: return the logged-in user (incl. admin flag) from your
  /// existing session instead of reading the users document.
  final Future<CommunityUser> Function()? _currentUserLoader;

  CollectionReference<Map<String, dynamic>> get _communities =>
      _db.collection(CommunityConfig.communitiesCollection);

  CollectionReference<Map<String, dynamic>> _messages(String communityId) =>
      _communities.doc(communityId).collection(CommunityConfig.messagesCollection);

  // ---------------------------------------------------------------- users

  Future<CommunityUser> loadCurrentUser() async {
    final loader = _currentUserLoader;
    if (loader != null) return loader();

    final user = _auth.currentUser;
    if (user == null) {
      throw const CommunityException('Please sign in again.');
    }
    final snap =
        await _db.collection(CommunityConfig.usersCollection).doc(user.uid).get();
    return CommunityUser.fromMap(user.uid, snap.data());
  }

  Future<List<CommunityUser>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final result = <CommunityUser>[];
    // Firestore `whereIn` accepts at most 10 values.
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snap = await _db
          .collection(CommunityConfig.usersCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      result.addAll(snap.docs.map((d) => CommunityUser.fromMap(d.id, d.data())));
    }
    return result;
  }

  /// Users that can be added to a community (non-admins, not excluded).
  Future<List<CommunityUser>> getParticipantCandidates({
    required Set<String> excludeIds,
  }) async {
    final snap =
        await _db.collection(CommunityConfig.usersCollection).limit(500).get();
    final users = snap.docs
        .map((d) => CommunityUser.fromMap(d.id, d.data()))
        .where((u) => !u.isAdmin && !excludeIds.contains(u.id))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return users;
  }

  // ----------------------------------------------------------- communities

  Stream<List<CommunityModel>> watchCommunities(CommunityUser user) {
    final Query<Map<String, dynamic>> query = user.isAdmin
        ? _communities.where('adminId', isEqualTo: user.id)
        : _communities.where('participantIds', arrayContains: user.id);

    return query.snapshots().map((snap) {
      final list = snap.docs.map(CommunityModel.fromDoc).toList()
        ..sort((a, b) => b.sortTime.compareTo(a.sortTime));
      return list;
    });
  }

  Stream<CommunityModel?> watchCommunity(String communityId) {
    return _communities
        .doc(communityId)
        .snapshots()
        .map((doc) => doc.exists ? CommunityModel.fromDoc(doc) : null);
  }

  Future<String> createCommunity({
    required CommunityUser admin,
    required String name,
    required String description,
    required List<String> participantIds,
    File? image,
  }) async {
    final doc = _communities.doc();
    await doc.set({
      'name': name,
      'description': description,
      'imageUrl': null,
      'adminId': admin.id,
      'participantIds':
          participantIds.where((id) => id != admin.id).toSet().toList(),
      'participantsCanMessage': false,
      'lastMessagePreview': null,
      'lastMessageType': null,
      'lastMessageAt': null,
      'unreadCounts': <String, int>{},
      'createdAt': Timestamp.now(),
    });

    if (image != null) {
      try {
        final url = await _upload(
          path:
              '${CommunityConfig.storageRoot}/${doc.id}/profile/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          file: image,
        );
        await doc.update({'imageUrl': url});
      } catch (_) {
        // Do not leave a half-created community behind.
        await doc.delete();
        rethrow;
      }
    }
    return doc.id;
  }

  /// Admin edits name / description / picture. A new picture replaces the old
  /// one (the old file is deleted); [removeImage] clears the picture.
  Future<void> updateCommunity({
    required String communityId,
    required String name,
    required String description,
    String? currentImageUrl,
    File? newImage,
    bool removeImage = false,
  }) async {
    final update = <String, dynamic>{
      'name': name,
      'description': description,
    };

    String? uploadedUrl;
    if (newImage != null) {
      if (await newImage.length() > CommunityConfig.maxImageBytes) {
        throw CommunityException(
            'Image is too large. Maximum size is ${CommunityConfig.maxImageBytes ~/ (1024 * 1024)} MB.');
      }
      uploadedUrl = await _upload(
        path:
            '${CommunityConfig.storageRoot}/$communityId/profile/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        file: newImage,
      );
      update['imageUrl'] = uploadedUrl;
    } else if (removeImage) {
      update['imageUrl'] = null;
    }

    try {
      await _communities.doc(communityId).update(update);
    } catch (_) {
      if (uploadedUrl != null) await _deleteByUrl(uploadedUrl);
      rethrow;
    }

    // Clean up the replaced / removed picture.
    if ((newImage != null || removeImage) &&
        currentImageUrl != null &&
        currentImageUrl.isNotEmpty) {
      await _deleteByUrl(currentImageUrl);
    }
  }

  Future<void> addParticipants(String communityId, List<String> userIds) {
    return _communities.doc(communityId).update({
      'participantIds': FieldValue.arrayUnion(userIds),
    });
  }

  Future<void> removeParticipant(String communityId, String userId) {
    return _communities.doc(communityId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'unreadCounts.$userId': FieldValue.delete(),
    });
  }

  Future<void> setParticipantsCanMessage(String communityId, bool enabled) {
    return _communities.doc(communityId).update({
      'participantsCanMessage': enabled,
    });
  }

  /// "Clear chat": hides all current messages for THIS user only.
  Future<void> clearChat(String communityId, String userId) {
    return _communities.doc(communityId).update({
      'clearedAt.$userId': Timestamp.now(),
      'unreadCounts.$userId': 0,
    });
  }

  /// A participant leaves the community (the admin cannot leave).
  Future<void> leaveCommunity(String communityId, CommunityUser user) async {
    if (user.isAdmin) {
      throw const CommunityException('The admin cannot leave the community.');
    }
    await _communities.doc(communityId).update({
      'participantIds': FieldValue.arrayRemove([user.id]),
      'unreadCounts.${user.id}': FieldValue.delete(),
      'clearedAt.${user.id}': FieldValue.delete(),
    });
  }

  Future<void> markRead(String communityId, String userId) {
    return _communities.doc(communityId).update({'unreadCounts.$userId': 0});
  }

  // -------------------------------------------------------------- messages

  Stream<List<CommunityMessage>> watchMessages(String communityId,
      {required int limit}) {
    return _messages(communityId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(CommunityMessage.fromDoc).toList());
  }

  /// Needs a composite index (type ASC, createdAt DESC) – see README.
  Stream<List<CommunityMessage>> watchMedia(String communityId) {
    return _messages(communityId)
        .where('type', whereIn: ['image', 'video', 'audio'])
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) => snap.docs
            .map(CommunityMessage.fromDoc)
            .where((m) => !m.isDeleted)
            .toList());
  }

  Future<void> sendMessage({
    required String communityId,
    required CommunityUser sender,
    required CommunityMessageType type,
    String? text,
    File? file,
    List<String> recipientIds = const [],
  }) async {
    String? mediaUrl;
    String? fileName;

    if (type.isMedia) {
      if (file == null) {
        throw const CommunityException('No file selected.');
      }
      final maxBytes = switch (type) {
        CommunityMessageType.image => CommunityConfig.maxImageBytes,
        CommunityMessageType.video => CommunityConfig.maxVideoBytes,
        _ => CommunityConfig.maxAudioBytes,
      };
      if (await file.length() > maxBytes) {
        throw CommunityException(
            'File is too large. Maximum size is ${maxBytes ~/ (1024 * 1024)} MB.');
      }
      fileName = file.uri.pathSegments.last;
      mediaUrl = await _upload(
        path:
            '${CommunityConfig.storageRoot}/$communityId/media/${DateTime.now().millisecondsSinceEpoch}_$fileName',
        file: file,
      );
    }

    try {
      // ONE batch: the message and the community's last-message fields are
      // written together, so the chat jumps to the top of the list at once
      // (the list is sorted by `lastMessageAt`, newest first).
      final messageRef = _messages(communityId).doc();
      final batch = _db.batch();
      batch.set(messageRef, {
        'senderId': sender.id,
        'senderName': sender.name,
        'senderIsAdmin': sender.isAdmin,
        'type': type.name,
        'text': text,
        'mediaUrl': mediaUrl,
        'fileName': fileName,
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(_communities.doc(communityId), {
        // Everyone except the sender gets +1 unread (shown as the badge).
        for (final uid in recipientIds.toSet().difference({sender.id}))
          'unreadCounts.$uid': FieldValue.increment(1),
        // Admin: plain preview. Participant: "Name: preview".
        'lastMessagePreview': sender.isAdmin
            ? _previewOf(type, text)
            : '${sender.name}: ${_previewOf(type, text)}',
        'lastMessageType': type.name,
        // Client time (not a pending server timestamp) so the sort order is
        // correct immediately; the Cloud Function later stores server time.
        'lastMessageAt': Timestamp.now(),
      });
      await batch.commit();
    } catch (_) {
      if (mediaUrl != null) await _deleteByUrl(mediaUrl);
      rethrow;
    }
  }

  String _previewOf(CommunityMessageType type, String? text) {
    switch (type) {
      case CommunityMessageType.image:
        return '📷 Photo';
      case CommunityMessageType.video:
        return '🎥 Video';
      case CommunityMessageType.audio:
        return '🎵 Audio';
      case CommunityMessageType.text:
        final t = (text ?? '').trim();
        return t.length > 120 ? '${t.substring(0, 117)}...' : t;
    }
  }

  /// Soft delete: keeps ordering intact, removes content and the stored file.
  Future<void> deleteMessage(String communityId, CommunityMessage message) async {
    await _messages(communityId).doc(message.id).update({
      'isDeleted': true,
      'text': null,
      'mediaUrl': null,
      'fileName': null,
    });
    final url = message.mediaUrl;
    if (url != null) await _deleteByUrl(url);
  }

  // --------------------------------------------------------------- storage

  Future<String> _upload({required String path, required File file}) async {
    final ref = _storage.ref(path);
    final task =
        await ref.putFile(file, SettableMetadata(contentType: _contentType(file.path)));
    return task.ref.getDownloadURL();
  }

  Future<void> _deleteByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // The message is already removed; a leftover file is not fatal.
    }
  }

  String _contentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'heic': 'image/heic',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'm4v': 'video/x-m4v',
      '3gp': 'video/3gpp',
      'mp3': 'audio/mpeg',
      'm4a': 'audio/mp4',
      'aac': 'audio/aac',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}