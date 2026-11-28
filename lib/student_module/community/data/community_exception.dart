import 'package:firebase_core/firebase_core.dart';

class CommunityException implements Exception {
  const CommunityException(this.message);

  final String message;

  @override
  String toString() => message;

  /// Converts any error into a message that is safe to show to the user.
  static String messageOf(Object error) {
    if (error is CommunityException) return error.message;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
        case 'unauthorized':
          return "You don't have permission to do this.";
        case 'unavailable':
        case 'network-request-failed':
          return 'Network problem. Please check your connection.';
        case 'not-found':
        case 'object-not-found':
          return 'The requested item was not found.';
        case 'canceled':
          return 'Upload cancelled.';
      }
      return error.message ?? 'Something went wrong. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
