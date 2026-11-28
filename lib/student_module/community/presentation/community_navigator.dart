import 'package:flutter/material.dart';
import 'package:game_edu/student_module/community/presentation/widgets/edit_community_screen.dart';

import '../data/models/community_message.dart';
import '../data/models/community_model.dart';
import '../notification/community_notification_handler.dart';
import 'common/community_chat_screen.dart';
import 'common/community_details_screen.dart';
import 'common/create_community_screen.dart';
import 'common/media_viewer_screen.dart';
import 'common/participant_picker_screen.dart';

/// All navigation of the Community feature in one place.
class CommunityNavigator {
  CommunityNavigator._();

  static Future<void> openChat(BuildContext context, String communityId) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityChatScreen(communityId: communityId),
      ),
    );
  }

  /// Used by notification taps (no BuildContext available).
  static Future<void> openChatWithKey(
    GlobalKey<NavigatorState> navigatorKey,
    String communityId,
  ) async {
    if (CommunityNotificationHandler.activeCommunityId == communityId) return;
    await navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityChatScreen(communityId: communityId),
      ),
    );
  }

  static Future<void> openDetails(BuildContext context, String communityId) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityDetailsScreen(communityId: communityId),
      ),
    );
  }

  /// Resolves with the new community id, or null if cancelled.
  static Future<String?> openCreate(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const CreateCommunityScreen()),
    );
  }

  /// Resolves with what the admin changed, or null if nothing changed.
  static Future<EditCommunityResult?> openEdit(
    BuildContext context,
    CommunityModel community,
  ) {
    return Navigator.of(context).push<EditCommunityResult>(
      MaterialPageRoute<EditCommunityResult>(
        builder: (_) => EditCommunityScreen(community: community),
      ),
    );
  }

  /// Resolves with the selected user ids, or null if cancelled.
  static Future<List<String>?> openParticipantPicker(
    BuildContext context, {
    Set<String> excludeIds = const {},
    Set<String> initialSelected = const {},
    String title = 'Select participants',
  }) {
    return Navigator.of(context).push<List<String>>(
      MaterialPageRoute<List<String>>(
        builder: (_) => ParticipantPickerScreen(
          excludeIds: excludeIds,
          initialSelected: initialSelected,
          title: title,
        ),
      ),
    );
  }

  static Future<void> openMedia(BuildContext context, CommunityMessage message) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MediaViewerScreen(message: message)),
    );
  }
}