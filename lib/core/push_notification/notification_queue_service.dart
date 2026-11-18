// =============================================================================
// FILE: lib/services/notification_queue_service.dart
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationQueueService {
  NotificationQueueService._();

  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

static Future<({bool success, String? queueId})> scheduleNotification({
  required String sessionType,
  required DateTime sendAt,
  required String title,
  required String body,
  required List<String> recipientUids,
  required String clickAction,
  required String route,
  Map<String, dynamic>? additionalData,
}) async {
  try {
    if (recipientUids.isEmpty) {
      debugPrint('⏰ [NotificationQueue] No recipients provided');
      return (success: false, queueId: null);
    }

    // Skip if sendAt is already in the past
    // if (sendAt.isBefore(DateTime.now())) {
    //   debugPrint('⏰ [NotificationQueue] sendAt is in the past, skipping');
    //   return (success: false, queueId: null);
    // }

    final uniqueUids = recipientUids.toSet().toList();
    debugPrint(
        '⏰ [NotificationQueue] Scheduling: sessionType=$sessionType, recipients=${uniqueUids.length}');

    final docRef = _db.collection('notificationQueue').doc();
    await docRef.set({
      'sessionType': sessionType,
      'sendAt': Timestamp.fromDate(sendAt),
      'title': title,
      'body': body,
      'recipientUids': uniqueUids,
      'clickAction': clickAction,
      'route': route,
      'additionalData': additionalData ?? {},
      'sent': false,
      'cancelled': false,
      'createdAt': Timestamp.now(),
      'createdBy': _auth.currentUser?.uid ?? 'unknown',
      'sentAt': null,
    });

    debugPrint('✅ [NotificationQueue] Scheduled: queueId=${docRef.id}');
    return (success: true, queueId: docRef.id);
  } catch (e) {
    debugPrint('❌ [NotificationQueue] Error: $e');
    return (success: false, queueId: null);
  }
}
  // Cancel a notification
static Future<bool> cancelNotification(String queueId) async {
  try {
    debugPrint('⏰ [NotificationQueue] Cancelling: $queueId');
    await _db.collection('notificationQueue').doc(queueId).update({
      'sent': true,
      'cancelled': true,
      'cancelledAt': Timestamp.now(),
      'sentAt': Timestamp.now(),  // ← ADD: needed by cleanup query
    });
    debugPrint('✅ [NotificationQueue] Cancelled: $queueId');
    return true;
  } catch (e) {
    debugPrint('❌ [NotificationQueue] Error cancelling: $e');
    return false;
  }
}

  // Cancel multiple notifications
  static Future<({int successCount, int errorCount})> cancelNotifications(
    List<String> queueIds,
  ) async {
    debugPrint(
        '⏰ [NotificationQueue] Batch cancelling ${queueIds.length} notifications');

    int successCount = 0;
    int errorCount = 0;

    for (final queueId in queueIds) {
      final success = await cancelNotification(queueId);
      if (success) {
        successCount++;
      } else {
        errorCount++;
      }
    }

    debugPrint(
        '✅ [NotificationQueue] Batch complete: $successCount success, $errorCount errors');

    return (successCount: successCount, errorCount: errorCount);
  }
}