import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupCallHeartbeatService {
  static Timer? _timer;
  static String? _currentCallId;

  static Future<void> start(String callId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    _currentCallId = callId;

    // Step 1: Write heartbeat + joinTime FIRST
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .update({
      'participantHeartbeats.$currentUserId': FieldValue.serverTimestamp(),
      'participantJoinTimes.$currentUserId': FieldValue.serverTimestamp(),
    });

    // Step 2: Now safe to add to activeParticipants
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .update({
      'activeParticipants': FieldValue.arrayUnion([currentUserId]),
    });

    // Step 3: Start periodic heartbeat
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        try {
          await FirebaseFirestore.instance
              .collection('calls')
              .doc(callId)
              .update({
            'participantHeartbeats.$currentUserId': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      },
    );
  }

  static Future<void> stop() async {
    _timer?.cancel();
    _timer = null;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || _currentCallId == null) return;

    final callId = _currentCallId!;
    _currentCallId = null;

    try {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(callId)
          .update({
        'activeParticipants': FieldValue.arrayRemove([currentUserId]),
        'participantHeartbeats.$currentUserId': FieldValue.delete(),
        'participantJoinTimes.$currentUserId': FieldValue.delete(),
      });
    } catch (_) {}
  }
}