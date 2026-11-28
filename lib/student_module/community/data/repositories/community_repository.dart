import 'dart:io';

import '../../community_config.dart';
import '../community_exception.dart';
import '../models/community_message.dart';
import '../models/community_model.dart';
import '../models/community_user.dart';
import '../services/community_firebase_service.dart';

/// Business rules for communities. Blocs talk only to this class.
class CommunityRepository {
  CommunityRepository({
    CommunityFirebaseService? service,
    Future<CommunityUser> Function()? currentUserLoader,
  })  : _service = service ?? CommunityFirebaseService(),
        _currentUserLoader = currentUserLoader;

  /// Shared instance used by the screens. Replace it at app start if you want
  /// to inject your own auth/user loader:
  /// `CommunityRepository.instance = CommunityRepository(currentUserLoader: ...)`
  static CommunityRepository instance = CommunityRepository();

  final CommunityFirebaseService _service;

  /// Optional hook: return the logged-in user from your existing auth/session
  /// layer (incl. the admin flag) instead of reading the `users` document.
  final Future<CommunityUser> Function()? _currentUserLoader;

  Future<CommunityUser> loadCurrentUser() =>
      _guard(() => (_currentUserLoader ?? _service.loadCurrentUser)());

  // ----------------------------------------------------------- communities

  Stream<List<CommunityModel>> watchCommunities(CommunityUser user) =>
      _service.watchCommunities(user);

  Stream<CommunityModel?> watchCommunity(String communityId) =>
      _service.watchCommunity(communityId);

  Future<String> createCommunity({
    required String name,
    required String description,
    required List<String> participantIds,
    File? image,
  }) {
    return _guard(() async {
      final admin = await loadCurrentUser();
      if (!admin.isAdmin) {
        throw const CommunityException('Only admins can create communities.');
      }
      return _service.createCommunity(
        admin: admin,
        name: name.trim(),
        description: description.trim(),
        participantIds: participantIds,
        image: image,
      );
    });
  }

  Future<void> addParticipants(String communityId, List<String> userIds) =>
      _guard(() => _service.addParticipants(communityId, userIds));

  Future<void> removeParticipant(String communityId, String userId) =>
      _guard(() => _service.removeParticipant(communityId, userId));

  Future<void> setParticipantsCanMessage(String communityId, bool enabled) =>
      _guard(() => _service.setParticipantsCanMessage(communityId, enabled));

  Future<void> markRead(String communityId, String userId) =>
      _guard(() => _service.markRead(communityId, userId));

  // ----------------------------------------------------------------- users

  Future<List<CommunityUser>> getUsersByIds(List<String> ids) =>
      _guard(() => _service.getUsersByIds(ids));

  Future<List<CommunityUser>> getParticipantCandidates(
          {Set<String> excludeIds = const {}}) =>
      _guard(() => _service.getParticipantCandidates(excludeIds: excludeIds));

  // -------------------------------------------------------------- messages

  Stream<List<CommunityMessage>> watchMessages(String communityId,
          {required int limit}) =>
      _service.watchMessages(communityId, limit: limit);

  Stream<List<CommunityMessage>> watchMedia(String communityId) =>
      _service.watchMedia(communityId);

  Future<void> sendText({
    required String communityId,
    required CommunityUser sender,
    required String text,
  }) {
    return _guard(() => _service.sendMessage(
          communityId: communityId,
          sender: sender,
          type: CommunityMessageType.text,
          text: text.trim(),
        ));
  }

  Future<void> sendMedia({
    required String communityId,
    required CommunityUser sender,
    required CommunityMessageType type,
    required File file,
  }) {
    return _guard(() async {
      final size = await file.length();
      final max = switch (type) {
        CommunityMessageType.image => CommunityConfig.maxImageBytes,
        CommunityMessageType.video => CommunityConfig.maxVideoBytes,
        _ => CommunityConfig.maxAudioBytes,
      };
      if (size > max) {
        throw CommunityException(
            'File is too large. Maximum size is ${max ~/ (1024 * 1024)} MB.');
      }
      await _service.sendMessage(
        communityId: communityId,
        sender: sender,
        type: type,
        file: file,
      );
    });
  }

  Future<void> deleteMessage(String communityId, CommunityMessage message) =>
      _guard(() => _service.deleteMessage(communityId, message));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CommunityException {
      rethrow;
    } catch (e) {
      throw CommunityException(CommunityException.messageOf(e));
    }
  }
}
