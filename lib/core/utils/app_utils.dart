import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:game_edu/common/constants/typography/app_fonts.dart';
import 'package:game_edu/common/constants/typography/font_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/firebase/firebase_initialization.dart';
import 'package:game_edu/core/responsive/responsive_sizes.dart';
import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/core/utils/share_link_constant.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:windows_toast/windows_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class AppUtils {
  static bool showCalls = false;

  static Widget clickable({
    required Widget child,
    VoidCallback? onTap,
    MouseCursor cursor = SystemMouseCursors.click,
  }) {
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }



  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static Future<void> goToSearch({
    required BuildContext context,
    required String tagName,
  }) {
    final arguments = <String, dynamic>{"tagName": tagName};

    return Navigator.pushNamed(
      context,
      RouterPath.search,
      arguments: arguments,
    );
  }

  static Future<Uint8List> compressImage(
    Uint8List bytes,
    String fileName,
  ) async {
    final ext = path.extension(fileName).toLowerCase();

    final format = switch (ext) {
      '.png' => CompressFormat.png,
      '.webp' => CompressFormat.webp,
      _ => CompressFormat.jpeg,
    };

    final result = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 85,
      format: format,
    );

    // debugPrint(
    //   '[compressImage] $fileName: '
    //   '${bytes.lengthInBytes ~/ 1024} KB → ${result.lengthInBytes ~/ 1024} KB',
    // );

    return Uint8List.fromList(result);
  }

  static StrutStyle tightStrut = const StrutStyle(
    height: 1,
    forceStrutHeight: true,
  );

  static void showToast({
    required BuildContext context,
    required String message,
  }) {
    WindowsToast.show(
      message,
      context,
      80,
      textStyle: const TextStyle(color: Colors.white),
    );
  }

  static String getInitials(String? name) {
    if (name == null) return '';

    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';

    final parts = trimmed.split(RegExp(r'\s+'));

    // Take first 2 valid parts only
    final initials = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return initials.isNotEmpty ? initials : '';
  }

  static Widget buildAvatar({
    required String? url,
    double size = 30,
    String? name,
  }) {
    final hasImage = url != null && url.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppPalette.elevatedSurfaceColor,
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                url,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (_, __, ___) {
                  return _buildAvatarFallback(name, size);
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return _buildAvatarFallback(name, size);
                },
              )
            : _buildAvatarFallback(name, size),
      ),
    );
  }

  static Widget _buildAvatarFallback(String? name, double size) {
    return Container(
      alignment: Alignment.center,
      color: AppPalette.elevatedSurfaceColor,
      child: Text(
        AppUtils.getInitials(name ?? ''),
        style: TextStyle(
          color: AppPalette.textPrimaryColor,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
        ),
      ),
    );
  }

  static Widget buildCircularText({
    required String? url,
    double size = 30,
    double fontSize = CardLabel.large,
  }) {
    return ClipOval(
      child: Container(
        alignment: Alignment.topCenter,
        color: AppPalette.elevatedSurfaceColor,
        width: size,
        height: size,
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: fontSize / 3),
          child: Text(
            (url ?? '').toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: AppFonts.calibrib,
              color: AppPalette.textPrimaryColor,
            ),

            // frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            //   if (frame != null || wasSynchronouslyLoaded) {
            //     // SUCCESS → with border
            //     return Container(
            //       decoration: const BoxDecoration(
            //         shape: BoxShape.circle,
            //         // border: Border.all(
            //         //   color: AppPalette.pinkColor,
            //         //   width: borderWidth,
            //         // ),
            //       ),
            //       child: ClipOval(child: child),
            //     );
            //   }

            //   return const SizedBox();

            //   // While loading → keep space
            //   // return Opacity(
            //   //   opacity: 0.5,
            //   //   child: ClipOval(
            //   //     child: Image.asset(ImageAssets.profileIcon, fit: BoxFit.cover),
            //   //   ),
            //   // );
            // },
            // errorBuilder: (_, __, ___) {
            //   // ERROR → same size, NO border
            //   return ClipOval(
            //     child: Container(color: AppPalette.elevatedSurfaceColor),
            //   );
            // },
          ),
        ),
      ),
    );
  }

  // static Future<void> createNotification({
  //   required String receiverId,
  //   required String senderId,
  //   required String type,
  //   String? payloadRef,
  // }) async {
  //   if (receiverId == senderId) return;

  //   await FirebaseFirestore.instance.collection('notifications').add({
  //     'receiverId': receiverId,
  //     'senderId': senderId,
  //     'type': type,
  //     'payloadRef': payloadRef,
  //     'isRead': false,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   });
  // }
  /// Call this right after a comment is successfully written.
  /// Fully self-contained: resolves the post owner, checks prefs,
  /// creates the in-app notification, and sends the push — all in one place.
  /// Does NOT touch createNotification().
  static Future<void> notifyPostComment({
    required String postId,
    required String senderId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// 1. RESOLVE POST OWNER
      final postDoc = await firestore
          .collection('createPosts')
          .doc(postId)
          .get();
      final receiverId = postDoc.data()?['uid'] as String?;

      if (receiverId == null || receiverId.isEmpty) return;
      if (receiverId == senderId) return; // no self-notify

      /// 2. CHECK PREFS
      final prefDoc = await firestore
          .collection('notificationPrefs')
          .doc(receiverId)
          .get();

      final prefs = prefDoc.data() ?? {};

      final commentsAllowed = prefs['comments'] ?? true;
      if (!commentsAllowed) return;

      final pushEnabled = prefs['pushEnabled'] ?? true;

      /// 3. CREATE IN-APP NOTIFICATION
      await firestore.collection('notifications').add({
        'receiverId': receiverId,
        'senderId': senderId,
        'type': 'comment',
        'payloadRef': postId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      /// 4. SEND PUSH (only if pushEnabled is also true)
      if (pushEnabled) {
        final receiverDoc = await firestore
            .collection('users')
            .doc(receiverId)
            .get();
        final receiverToken = receiverDoc.data()?['pushToken'];

        if (receiverToken == null || receiverToken.isEmpty) return;

        final senderDoc = await firestore
            .collection('users')
            .doc(senderId)
            .get();
        final senderName = senderDoc.data()?['profileName'] ?? "Someone";

        await FirebaseInitialization.sendNormalNotification(
          receiverToken: receiverToken,
          title: "New Comment",
          body: "$senderName commented on your post",
          route: "post_detail",
          payload: {"postId": postId, "clickAction": postId},
          receiverId: receiverId,
        );
      }
    } catch (e) {
      debugPrint("notifyPostComment error: $e");
    }
  }

  static Future<void> createNotification({
    required String receiverId,
    required String senderId,
    required String type,
    String? payloadRef,
  }) async {
    if (receiverId == senderId) return;

    final firestore = FirebaseFirestore.instance;

    try {
      final prefDoc = await firestore
          .collection('notificationPrefs')
          .doc(receiverId)
          .get();

      /// 2. If no prefs → allow by default
      if (prefDoc.exists) {
        final prefs = prefDoc.data()!;

        /// 3. Check global toggle
        //  if (prefs['inAppEnabled'] == false) return;

        /// 4. Check type-based toggle
        bool isAllowed = true;

        switch (type) {
          case "follow":
            isAllowed = prefs['newFollowers'] ?? true;
            if (isAllowed) {
              _sendFollowPush(receiverId: receiverId, senderId: senderId);
            }
            break;

          case "like":
            isAllowed = prefs['likes'] ?? true;

            final pushEnabled = prefs['pushEnabled'] ?? true;

            if (isAllowed && pushEnabled && payloadRef != null) {
              await _sendLikePush(
                receiverId: receiverId,
                senderId: senderId,
                postId: payloadRef,
              );
            }
            break;

          case "comment":
            isAllowed = prefs['comments'] ?? true;

            final pushEnabled = prefs['pushEnabled'] ?? true;

            if (isAllowed && pushEnabled && payloadRef != null) {
              await _sendCommentPush(
                receiverId: receiverId,
                senderId: senderId,
                postId: payloadRef,
              );
            }
            break;

          case "mention":
            isAllowed = prefs['mentions'] ?? true;
            break;

          case "connection_request":
            isAllowed = prefs['connections'] ?? true;
            if (isAllowed) {
              _sendConnectionPush(receiverId: receiverId, senderId: senderId);
            }
            break;
        }

        if (!isAllowed) return;
      }

      /// 5. Create notification
      await firestore.collection('notifications').add({
        'receiverId': receiverId,
        'senderId': senderId,
        'type': type,
        'payloadRef': payloadRef,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("createNotification error: $e");
    }
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    return doc.data();
  }

  static Future<void> _sendConnectionPush({
    required String receiverId,
    required String senderId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// Get receiver token
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) return;

      final senderDoc = await firestore.collection('users').doc(senderId).get();

      final senderName = senderDoc.data()?['profileName'] ?? "notFound";

      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,
        title: "New Connection Request",
        body: "$senderName sent you a connection request",
        route: "connection",
        payload: {
          "payload": jsonEncode({"userId": senderId, "type": "request"}),
        },
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Connection push error: $e");
    }
  }

  static Future<void> _sendFollowPush({
    required String receiverId,
    required String senderId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// Get receiver token
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) return;

      final senderDoc = await firestore.collection('users').doc(senderId).get();

      final senderName = senderDoc.data()?['profileName'] ?? "notFound";

      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,
        title: "New Follower",
        body: "$senderName started following you",
        route: "profile",
        payload: {
          "payload": jsonEncode({"userId": senderId, "type": "follow"}),
        },
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Follow push error: $e");
    }
  }

  static Future<void> sendTeamInvitePush({
    required String receiverId,
    required String senderId,
    required String teamId,
    required String teamName,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// GET RECEIVER TOKEN
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) return;

      /// GET SENDER NAME
      final senderDoc = await firestore.collection('users').doc(senderId).get();

      final senderName = senderDoc.data()?['profileName'] ?? "Someone";

      /// SEND PUSH
      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,

        title: "Team Invite",

        body: "$senderName invited you to join $teamName",

        route: "user_member_request",

        payload: {"uid": receiverId},
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Team invite push error: $e");
    }
  }

  static Future<void> sendJoinRequestPush({
    required String receiverId,
    required String senderId,
    required String teamId,
    required String teamName,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// RECEIVER
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) {
        return;
      }

      /// SENDER
      final senderDoc = await firestore.collection('users').doc(senderId).get();

      final senderName = senderDoc.data()?['profileName'] ?? "Someone";

      /// SEND PUSH
      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,

        title: "Join Request",

        body: "$senderName requested to join $teamName",

        route: "member_request",

        payload: {"teamId": teamId, "index": 0},
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Join request push error: $e");
    }
  }

  static Future<void> sendTeamAcceptedPush({
    required String receiverId,
    required String teamId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// RECEIVER
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) {
        return;
      }

      /// TEAM
      final teamDoc = await firestore.collection('teams').doc(teamId).get();

      final teamName = teamDoc.data()?['teamName'] ?? 'Team';

      /// PUSH
      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,

        title: "Request Accepted",

        body: "Your request was accepted by $teamName",

        route: "teams",

        payload: {"teamId": teamId},
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Team accepted push error: $e");
    }
  }

  static Future<void> sendLiveStreamNotification({
    required String streamerId,
    required String streamName,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final subscribersSnap = await firestore
          .collection('users')
          .doc(streamerId)
          .collection('liveNotifySubscribers')
          .get();

      for (final subscriberDoc in subscribersSnap.docs) {
        final receiverId = subscriberDoc.id;

        final receiverDoc = await firestore
            .collection('users')
            .doc(receiverId)
            .get();

        final receiverToken = receiverDoc.data()?['pushToken'];

        if (receiverToken == null || receiverToken.isEmpty) continue;

        await FirebaseInitialization.sendNormalNotification(
          receiverToken: receiverToken,
          title: "Live Now",
          body: "$streamName is live!",
          route: "liveStream",
          payload: {"streamerId": streamerId},
          receiverId: receiverId,
        );
      }
    } catch (e) {
      debugPrint("Live stream notification error: $e");
    }
  }

  static Future<void> sendLiveStreamNotificationToFollowrs({
    required String streamerId,
    required String streamName,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final streamerDoc = await firestore
          .collection('users')
          .doc(streamerId)
          .get();

      final followers = List<String>.from(
        streamerDoc.data()?['followers'] ?? [],
      );

      for (final receiverId in followers) {
        final receiverDoc = await firestore
            .collection('users')
            .doc(receiverId)
            .get();

        final receiverToken = receiverDoc.data()?['pushToken'] as String?;

        if (receiverToken == null || receiverToken.isEmpty) {
          continue;
        }

        await FirebaseInitialization.sendNormalNotification(
          receiverToken: receiverToken,
          title: "Live Now",
          body: "$streamName is live!",
          route: "liveStream",
          payload: {"streamerId": streamerId},
          receiverId: receiverId,
        );
      }
    } catch (e) {
      debugPrint("Live stream notification error: $e");
    }
  }

  static Future<void> sendTeamDeclinedPush({
    required String receiverId,
    required String teamId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// RECEIVER
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) {
        return;
      }

      /// TEAM
      final teamDoc = await firestore.collection('teams').doc(teamId).get();

      final teamName = teamDoc.data()?['teamName'] ?? 'Team';

      /// PUSH
      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,

        title: "Request Declined",

        body: "$teamName declined your join request",

        route: "teams",

        payload: {"teamId": teamId},
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Team declined push error: $e");
    }
  }

  // Add this to your AppUtils class or create a new file

  static Future<void> sendMissedCallNotification({
    required String receiverId,
    required String callerId,
    required String callerName,
    required String callerPic,
    required String callId,
    required bool isAudioOnly,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];
      if (receiverToken == null || receiverToken.isEmpty) return;


      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,
        title: "Missed Call",
        body: "Missed call from  $callerName . Tap to call back",
        route: "missed_call",
        payload: {
          "callId": callId,
          "callerId": callerId,
          "callerName": callerName,
          "callerPic": callerPic,
          "isAudioOnly": isAudioOnly,
          "type": "missed_call",
        },
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Missed call notification error: $e");
    }
  }

  static Future<void> sendConnectionAcceptedNotification({
    required String receiverId,
    required String senderId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // await createNotification(
      //   receiverId: receiverId,
      //   senderId: senderId,
      //   type: "connection_accept",
      //   payloadRef: senderId,
      // );

      /// 🔥 2. Get receiver token
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) return;

      /// 🔥 3. Get sender name
      final senderDoc = await firestore.collection('users').doc(senderId).get();

      final senderName = senderDoc.data()?['profileName'] ?? "Someone";

      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,
        title: "Connection Accepted",
        body: "$senderName accepted your connection request",
        route: "profile",

        payload: {"userId": senderId},
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Accept notification error: $e");
    }
  }

  static Future<void> _sendLikePush({
    required String receiverId,
    required String senderId,
    required String postId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// Get receiver token
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) return;

      /// Get sender details
      final senderDoc = await firestore.collection('users').doc(senderId).get();

      final senderName = senderDoc.data()?['profileName'] ?? "Someone";

      /// Send push
      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,
        title: "New Like",
        body: "$senderName liked your post",
        route: "post_detail",
        payload: {"postId": postId, "clickAction": postId},
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Like push error: $e");
    }
  }

  static Future<void> _sendCommentPush({
    required String receiverId,
    required String senderId,
    required String postId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      /// Get receiver token
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final receiverToken = receiverDoc.data()?['pushToken'];

      if (receiverToken == null || receiverToken.isEmpty) return;

      /// Get sender details
      final senderDoc = await firestore.collection('users').doc(senderId).get();

      final senderName = senderDoc.data()?['profileName'] ?? "Someone";

      /// Send push
      await FirebaseInitialization.sendNormalNotification(
        receiverToken: receiverToken,
        title: "New Comment",
        body: "$senderName commented on your post",
        route: "post_detail",
        payload: {"postId": postId, "clickAction": postId},
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint("Comment push error: $e");
    }
  }
}

bool _isSharing = false;

Future<void> shareMessage(String message, BuildContext context) async {
  if (_isSharing) return;
  _isSharing = true;

  try {
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;

    Rect shareRect = Rect.fromLTWH(0, 0, screenWidth, screenHeight);

    if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;

      final versionString = iosInfo.systemVersion;
      final majorVersion = int.tryParse(versionString.split('.').first) ?? 0;

      if (majorVersion < 18) {
        shareRect = Rect.fromLTWH(screenWidth / 2, screenHeight / 2, 1, 1);
      }
    }

    await SharePlus.instance.share(
      ShareParams(sharePositionOrigin: shareRect, text: message),
    );
  } finally {
    _isSharing = false;
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

goToTermsOfUse() {
  // _launchUrl('https://www.revolutiongamesindia.com/terms-condition/');
  _launchUrl('${AppHostingConstant.baseUrl}/terms');
}

goToPrivacyPolicy() {
  // _launchUrl('https://playrevolutiongames.com/privacypolicy-store');
  _launchUrl('${AppHostingConstant.baseUrl}/terms');
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

class AppToast {
  // Guards against stacking multiple toasts at once. Set true right before
  // inserting the overlay entry, reset to false only when that entry is
  // actually removed (after its 3s life or manual dismissal via action).
  static bool _isShowing = false;

  static void show({
    required BuildContext context,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    ResponsiveSizes? deviceType,
    bool isTop = false,
    bool preventMultipleToast = false,
  }) {
    // A toast is already on screen — drop this call instead of stacking,
    // unless the caller explicitly opted out via preventMultipleToast: false.
    if (preventMultipleToast && _isShowing) return;

    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    final showFromTop = isTop || MediaQuery.of(context).viewInsets.bottom > 0;

    void removeEntry() {
      if (entry.mounted) entry.remove();
      _isShowing = false;
    }

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: showFromTop ? 60 : null,
        bottom: showFromTop ? null : 80,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: _ToastCard(
              message: message,
              actionText: actionText,
              onAction: () {
                removeEntry();
                onAction?.call();
              },
            ),
          ),
        ),
      ),
    );

    _isShowing = true;
    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), removeEntry);
  }
}

class _ToastCard extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const _ToastCard({required this.message, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.cardSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppPalette.elevatedSurfaceColor, //  subtle border
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ///  STATUS DOT
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppPalette.textSecondaryColor,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 12),

          ///  MESSAGE
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppPalette.textPrimaryColor,
                fontSize: 14,
              ),
            ),
          ),

          ///  ACTION BUTTON
          if (actionText != null) ...[
            const SizedBox(width: 12),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppPalette.primaryAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    color: AppPalette.buttonTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
