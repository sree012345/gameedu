/*
 * -----------------------------------------------------------------------------
 * File        : lib/core/services/email_service.dart
 * Description : Centralized email service using Firebase Cloud Functions
 *               backed by GoDaddy SMTP. Replaces the Firestore mail
 *               collection trigger approach.
 *
 * Functions Used:
 *   - sendEmail   : Generic branded transactional email
 *   - sendOtp     : Generates + sends OTP via email
 *   - verifyOtp   : Validates submitted OTP
 *
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-05-25
 * Last Updated: 2026-06-11
 * -----------------------------------------------------------------------------
 * © 2026 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class EmailService {
  EmailService._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );
  // ---------------------------------------------------------------------------
  // SEND EMAIL — by userId (fetches email from Firestore)
  // ---------------------------------------------------------------------------

  static Future<void> sendEmail({
    required String userId,
    required String title,
    required String subtitle,
    required String content,
  }) async {
    try {
      /// Fetch user email from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        debugPrint('EmailService: User not found');
        return;
      }

      final email = userDoc.data()?['email'];

      if (email == null || email.toString().trim().isEmpty) {
        debugPrint('EmailService: User email missing');
        return;
      }

      await sendEmailDirect(
        toEmail: email.toString().trim(),
        title: title,
        subtitle: subtitle,
        content: content,
      );
    } catch (e) {
      debugPrint('EmailService.sendEmail Error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SEND EMAIL — direct (toEmail known)
  // ---------------------------------------------------------------------------

  static Future<void> sendEmailDirect({
    required String toEmail,
    required String title,
    required String subtitle,
    required String content,
  }) async {
    try {
      if (toEmail.trim().isEmpty) {
        debugPrint('EmailService: toEmail is empty');
        return;
      }

      final result = await _functions.httpsCallable('sendEmail').call({
        'toEmail': toEmail.trim(),
        'title': title,
        'subtitle': subtitle,
        'content': content,
      });

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        debugPrint('EmailService: Email sent successfully to $toEmail');
      } else {
        debugPrint('EmailService: Failed — ${data['message']}');
      }
    } catch (e) {
      debugPrint('EmailService.sendEmailDirect Error: $e');
    }
  }
}
