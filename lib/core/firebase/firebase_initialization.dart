import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class FirebaseInitialization {
  static String fcmUrl =
      "https://us-central1-revogram-test.cloudfunctions.net/sendNotification";

  static String voipUrl =
      "https://us-central1-revogram-test.cloudfunctions.net/sendVoipPush";

  //  static String fcmUrl = "https://sendnotification-pgbucdxxyq-uc.a.run.app";

  // static String voipUrl = "https://sendvoippush-pgbucdxxyq-uc.a.run.app";

  static String getLiveToken =
      "https://apirevomeet.duckdns.org/get-livekit-token";

  static String startRecordingUrl =
      "https://apirevomeet.duckdns.org/start-recording";

  static String stopRecordingUrl =
      "https://apirevomeet.duckdns.org/stop-recording";

  static bool isFirebaseAppInitialized() {
    return Firebase.apps.isNotEmpty;
  }

  static Future<void> loadFirebaseInit() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCo2eZ0u5_MdI3M_5zRSH4t0xrKJHu0u9g",
            authDomain: "revogram-test.firebaseapp.com",
            projectId: "revogram-test",
            storageBucket: "revogram-test.firebasestorage.app",
            messagingSenderId: "468455985319",
            appId: "1:468455985319:web:32677aaeb9ff7e19a30b82",
            measurementId: "G-JZN1NW9RC2",
            databaseURL:
                "https://revogram-test-default-rtdb.asia-southeast1.firebasedatabase.app",
          ),
        );
      } else if (Platform.isWindows) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCo2eZ0u5_MdI3M_5zRSH4t0xrKJHu0u9g",
            authDomain: "revogram-test.firebaseapp.com",
            projectId: "revogram-test",
            storageBucket: "revogram-test.firebasestorage.app",
            messagingSenderId: "468455985319",
            appId: "1:468455985319:web:32677aaeb9ff7e19a30b82",
            measurementId: "G-JZN1NW9RC2",
            databaseURL:
                "https://revogram-test-default-rtdb.asia-southeast1.firebasedatabase.app",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      debugPrint('Firebase initialize error $e');
    }
  }

  static Future<void> loadAnalyticsInit() async {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> startGroupCall({
    required String receiverToken,
    required String callerId,
    required String callerName,
    required String callerPic,
    required String callerHandleName,
    required String callId,
    required String groupId,
    required String groupName,
    required String groupPic,
    required bool isAudioOnly,
    String callType = 'video',
  }) async {
    final Map<String, dynamic> payload = {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'callerHandleName': callerHandleName,
      'callId': callId,
      'groupId': groupId,
      'groupName': groupName,
      'groupPic': groupPic,
      'isAudioOnly': isAudioOnly,
      'type': 'group_call', // ← key difference from 1-to-1
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token':      receiverToken,
          'type':       'call',
          'callerName': callerName,
          'callType': isAudioOnly ? 'audio' : 'video',
          'payload': payload,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('📞 Group call FCM sent to token: $receiverToken');
      } else {
        debugPrint('❌ Group call FCM failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Group call FCM error: $e');
    }
  }

  /// Sends a VoIP push notification for a GROUP call (iOS only).
  static Future<void> startGroupCallVoip({
    required String receiverToken,
    required String callerId,
    required String callerName,
    required String callerPic,
    required String callerHandleName,
    required String callId,
    required String groupId,
    required String groupName,
    required String groupPic,
    required bool isAudioOnly,
  }) async {
    final Map<String, dynamic> payload = {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'callerHandleName': callerHandleName,
      'callId': callId,
      'groupId': groupId,
      'groupName': groupName,
      'groupPic': groupPic,
      'isAudioOnly': isAudioOnly,
      'type': 'group_call',
    };

    try {
      final response = await http.post(
        Uri.parse(voipUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'voipToken': receiverToken,
          'type': 'group_call',
          'callerName': groupName, // show group name on iOS lock screen
          'callType': isAudioOnly ? 'audio' : 'video',
          'payload': payload,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('📞 Group call VoIP sent to token: $receiverToken');
      } else {
        debugPrint('❌ Group call VoIP failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Group call VoIP error: $e');
    }
  }

  static Future<void> startCall({
    required String receiverToken,
    required String callerName,
    required String callerId,
    required String receiverId,
    required String receiverName,
    required String callId,
    required bool isAudioOnly,
    required String callerPic,
    required String receiverhandleName,
    required String callerHandleName,
    required String receiverPic,
    String? roomId,
    String callType = "video", // video | audio
    String? avatar,
    bool isGroupCall = false,
    Map<String, dynamic>? extraPayload,
  }) async {
    final String generatedRoomId =
        roomId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> payload = {
      "callerId": callerId,
      "avatar": avatar ?? "",
      "isGroupCall": isGroupCall,
      "callId": callId,
      "callerName": callerName,
      "receiverId": receiverId,
      "isAudioOnly": isAudioOnly,
      "callerPic": callerPic,
      "callerHandleName": callerHandleName,
      "receiverhandleName": receiverhandleName,
      "receiverPic": receiverPic,
      //  allow extending payload
      ...?extraPayload,
    };

    try {
      final response = await http.post(
        // Uri.parse(
        //   "https://us-central1-revogram-test.cloudfunctions.net/sendNotification",
        // ),
        Uri.parse(fcmUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": receiverToken,
          "type": "call",
          "callerName": callerName,
          "roomId": generatedRoomId,
          "callType": callType,
          "payload": payload,
        }),
      );

      if (response.statusCode == 200) {
        print("📞 Call notification sent");
      } else {
        print("❌ Failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending call: $e");
    }
  }

  static Future<void> sendNormalNotification({
    required String receiverToken,
    required String title,
    required String body,
    required String route,
    required String receiverId,
    Map<String, dynamic>? payload,
    String? imageUrl,
    String? clickAction,
  }) async {
    // final Uri url = Uri.parse(
    //   "https://us-central1-revogram-test.cloudfunctions.net/sendNotification",
    // );

      final prefsDoc = await FirebaseFirestore.instance
      .collection('notificationPrefs')
      .doc(receiverId)
      .get();

  final bool pushEnabled = prefsDoc.data()?['pushEnabled'] ?? true;

  if (!pushEnabled) {
    debugPrint("🔕 Push disabled for $receiverId — skipping");
    return;
  }

    final Uri url = Uri.parse(fcmUrl);
    // 👇 Ensure payload is always a map
    final Map<String, dynamic> finalPayload = {
      ...?payload,
      if (imageUrl != null) "imageUrl": imageUrl,
      if (clickAction != null) "clickAction": clickAction,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": receiverToken,
          "type": "normal",
          "title": title,
          "body": body,
          "route": route,
          "payload": finalPayload,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint(" Notification sent successfully");
      } else {
        debugPrint(" Failed to send notification: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error sending notification: $e");
    }
  }

  static Future<void> startVoipCall({
    required String receiverToken,
    required String callerName,
    required String callerId,
    required String receiverId,
    required String receiverName,
    required String callId,
    required bool isAudioOnly,
    required String callerPic,
    required String receiverhandleName,
    required String callerHandleName,
    required String receiverPic,
    String? roomId,
    String callType = "video", // video | audio
    String? avatar,
    bool isGroupCall = false,
    Map<String, dynamic>? extraPayload,
  }) async {
    final String generatedRoomId =
        roomId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> payload = {
      "callerId": callerId,
      "avatar": avatar ?? "",
      "isGroupCall": isGroupCall,
      "callId": callId,
      "callerName": callerName,
      "receiverId": receiverId,
      "isAudioOnly": isAudioOnly,
      "callerPic": callerPic,
      "callerHandleName": callerHandleName,
      "receiverhandleName": receiverhandleName,
      "receiverPic": receiverPic,
      //  allow extending payload
      ...?extraPayload,
    };

    try {
      final response = await http.post(
        Uri.parse(
          "https://us-central1-revogram-test.cloudfunctions.net/sendVoipPush",
        ),
        // Uri.parse(voipUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "voipToken": receiverToken,
          "type": "call",
          "callerName": callerName,
          "roomId": generatedRoomId,
          "callType": callType,
          "payload": payload,
        }),
      );

      print("VOIP response :: $response");

      if (response.statusCode == 200) {
        print("📞 Call notification sent");
      } else {
        print("❌ Failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending call: $e");
    }
  }

  static Future<void> startVoipCallForDev({
    required String receiverToken,
    required String callerName,
    required String callerId,
    required String receiverId,
    required String receiverName,
    required String callId,
    required bool isAudioOnly,
    required String callerPic,
    required String receiverhandleName,
    required String callerHandleName,
    required String receiverPic,
    String? roomId,
    String callType = "video", // video | audio
    String? avatar,
    bool isGroupCall = false,
    Map<String, dynamic>? extraPayload,
  }) async {
    final String generatedRoomId =
        roomId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> payload = {
      "callerId": callerId,
      "avatar": avatar ?? "",
      "isGroupCall": isGroupCall,
      "callId": callId,
      "callerName": callerName,
      "receiverId": receiverId,
      "isAudioOnly": isAudioOnly,
      "callerPic": callerPic,
      "callerHandleName": callerHandleName,
      "receiverhandleName": receiverhandleName,
      "receiverPic": receiverPic,
      //  allow extending payload
      ...?extraPayload,
    };

    try {
      final response = await http.post(
        Uri.parse(
          "https://us-central1-revogram-test.cloudfunctions.net/sendVoipPushForDev",
        ),
        // Uri.parse(voipUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "voipToken": receiverToken,
          "type": "call",
          "callerName": callerName,
          "roomId": generatedRoomId,
          "callType": callType,
          "payload": payload,
        }),
      );

      print("VOIP response :: $response");

      if (response.statusCode == 200) {
        print("📞 Call notification sent");
      } else {
        print("❌ Failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending call: $e");
    }
  }

  // static Future<Map<String, String>?> getLiveKitToken({
  //   required String roomName,
  //   required String participantName,
  //   required bool isBroadcaster,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(getLiveToken),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'room_name': roomName,
  //         'participant_name': participantName,
  //         'is_broadcaster': isBroadcaster,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       debugPrint('✅ LiveKit token received');
  //       return {
  //         'token': data['token'] as String,
  //         'url': data['url'] as String,
  //         'roomName': data['roomName'] as String,
  //       };
  //     } else {
  //       debugPrint('❌ getLiveKitToken failed: ${response.body}');
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('❌ getLiveKitToken error: $e');
  //     return null;
  //   }
  // }

  static Future<Map<String, String>?> getLiveKitToken({
  required String roomName,
  required String participantName,
  required bool isBroadcaster,
  // ── ADD THESE ──
  String? youtubeKey,
  String? twitchKey,
  String? facebookKey,
  String? instagramRtmpUrl,
  String? discordChannelId,
}) async {
  try {
    final response = await http.post(
      Uri.parse(getLiveToken),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'room_name': roomName,
        'participant_name': participantName,
        'is_broadcaster': isBroadcaster,
        // ── ADD THESE ──
        if (youtubeKey != null) 'youtube_key': youtubeKey,
        if (twitchKey != null) 'twitch_key': twitchKey,
        if (facebookKey != null) 'facebook_key': facebookKey,
        if (instagramRtmpUrl != null) 'instagram_rtmp_url': instagramRtmpUrl,
        if (discordChannelId != null) 'discord_channel_id': discordChannelId,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('✅ LiveKit token received');
      return {
        'token': data['token'] as String,
        'url': data['url'] as String,
        'roomName': data['roomName'] as String,
      };
    } else {
      debugPrint('❌ getLiveKitToken failed: ${response.body}');
      return null;
    }
  } catch (e) {
    debugPrint('❌ getLiveKitToken error: $e');
    return null;
  }
}

  // Starts RoomCompositeEgress for the given room.
  /// Returns the egressId on success, null on failure.
  static Future<String?> startRecording({required String roomName}) async {
  try {
    debugPrint("========== START RECORDING ==========");
    debugPrint("Room Name: $roomName");
    debugPrint("URL: $startRecordingUrl");

    final requestBody = {
      'room_name': roomName,
    };

    debugPrint("Request Headers:");
    debugPrint("{'Content-Type': 'application/json'}");

    debugPrint("Request Body:");
    debugPrint(jsonEncode(requestBody));

    final response = await http.post(
      Uri.parse(startRecordingUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    debugPrint("========== RESPONSE ==========");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response Headers: ${response.headers}");
    debugPrint("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

  debugPrint("Decoded Response:");
  debugPrint(data.toString());

  debugPrint("Egress ID: ${data['egress_id']}");

  return data['egress_id'] as String?;
    } else {
      debugPrint("❌ startRecording failed");
      return null;
    }
  } catch (e, stackTrace) {
    debugPrint("❌ startRecording error: $e");
    debugPrint("❌ StackTrace: $stackTrace");
    return null;
  } finally {
    debugPrint("========== END RECORDING ==========");
  }
}
  /// Stops the given egress recording.
  /// Returns true on success.
 static Future<String?> stopRecording({required String egressId}) async {
  try {
    debugPrint("========== STOP RECORDING ==========");
    debugPrint("Egress ID: $egressId");
    debugPrint("URL: $stopRecordingUrl");

    final requestBody = {
      'egress_id': egressId,
    };

    final response = await http.post(
      Uri.parse(stopRecordingUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
   final data = jsonDecode(response.body);

     final videoUrl = data['video_url'] as String?;

      debugPrint("✅ Video URL: $videoUrl");

      return videoUrl;
      
      
          } else {
      debugPrint("❌ stopRecording failed");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Error Response: ${response.body}");

      return null;
    }
  } catch (e, stackTrace) {
    debugPrint("❌ stopRecording error: $e");
    debugPrint("❌ StackTrace: $stackTrace");

    return null;
  } finally {
    debugPrint("========== END STOP RECORDING ==========");
  }
}
}
