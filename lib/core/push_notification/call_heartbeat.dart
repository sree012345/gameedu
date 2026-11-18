import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CallHeartbeatService {
  static Timer? _timer;

  /// START HEARTBEAT
  static void start({
    required String callId,
    required bool isCaller,
  }) {
    stop();

    _updateHeartbeat(
      callId: callId,
      isCaller: isCaller,
    );

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        _updateHeartbeat(
          callId: callId,
          isCaller: isCaller,
        );
      },
    );
  }

  /// UPDATE FIRESTORE
  static Future<void> _updateHeartbeat({
    required String callId,
    required bool isCaller,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(callId)
          .update({
        isCaller
            ? 'callerHeartbeatAt'
            : 'receiverHeartbeatAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Heartbeat error: $e");
    }
  }

  /// STOP HEARTBEAT
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}