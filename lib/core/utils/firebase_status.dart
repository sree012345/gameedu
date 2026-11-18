/*
 * -----------------------------------------------------------------------------
 * File        : lib\core\utils\firebase_status.dart
 * Description : FirebaseStatus - handles core functionality
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-04-28
 * Last Updated: 2026-04-28
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : FirebaseStatus
 * Purpose     : Defines a standardized way to represent the result of Firebase operations, 
 *               including success and failure states, along with associated messages and data.
 * -----------------------------------------------------------------------------
 */

enum FirebaseStatus { success, failure }

class FirebaseResult<T> {
  final FirebaseStatus status;
  final String message;
  final T? data;
  final Object? error;

  const FirebaseResult._({
    required this.status,
    required this.message,
    this.data,
    this.error,
  });

  factory FirebaseResult.success({T? data}) {
    return FirebaseResult._(
      status: FirebaseStatus.success,
      message: "Success",
      data: data,
    );
  }

  factory FirebaseResult.failure({required String message, Object? error}) {
    return FirebaseResult._(
      status: FirebaseStatus.failure,
      message: message,
      error: error,
    );
  }

  bool get isSuccess => status == FirebaseStatus.success;
  bool get isFailure => status == FirebaseStatus.failure;
}
