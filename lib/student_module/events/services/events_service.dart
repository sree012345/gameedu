import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_edu/core/config/server_config.dart';

import '../models/event_item.dart';

class EventsFailure implements Exception {
  const EventsFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Events + the user's registrations.
///
///  * events        : `${env}_events/{eventId}`
///  * registrations : `${env}_event_registrations/{uid}_{eventId}`
///      userId, eventId, eventTitle, fullName, email, phone, college,
///      studentId, registeredAt
class EventsService {
  EventsService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const EventsFailure(
        'Session expired. Please login again.',
        code: 'no-user',
      );
    }
    return user;
  }

  /// Upcoming events, soonest first (past events are hidden).
  Future<List<EventItem>> fetchEvents() async {
    try {
      // Single-field range + orderBy: no composite index needed.
      final snapshot = await _firestore
          .collection(ServerConfig.eventsCollection)
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('eventDate')
          .get();

      final events = <EventItem>[];
      for (final doc in snapshot.docs) {
        final event = EventItem.tryFromDoc(doc);
        if (event != null) events.add(event);
      }
      return events;
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not load events');
    }
  }

  /// Ids of the events the logged-in user already registered for.
  Future<Set<String>> fetchRegisteredEventIds() async {
    final user = _requireUser();

    try {
      final snapshot = await _firestore
          .collection(ServerConfig.eventRegistrationsCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      return {
        for (final doc in snapshot.docs)
          if ((doc.data()['eventId'] ?? '').toString().isNotEmpty)
            doc.data()['eventId'].toString(),
      };
    } on FirebaseException catch (e) {
      throw _map(e, 'Could not load your registrations');
    }
  }

  /// Registers the logged-in user. One registration per user per event
  /// (document id = `{uid}_{eventId}`).
  Future<void> register(EventItem event) async {
    final user = _requireUser();

    if (!event.isRegistrationOpen(DateTime.now())) {
      throw const EventsFailure('Registration is closed for this event');
    }

    // Contact details for the organiser (from the profile, Auth as fallback)
    Map<String, dynamic> profile = const {};
    try {
      final doc = await _firestore
          .collection(ServerConfig.usersCollection)
          .doc(user.uid)
          .get();
      profile = doc.data() ?? const {};
    } on FirebaseException {
      profile = const {};
    }

    String pick(String key, String? fallback) {
      final v = (profile[key] ?? '').toString().trim();
      return v.isNotEmpty ? v : (fallback ?? '');
    }

    try {
      await _firestore
          .collection(ServerConfig.eventRegistrationsCollection)
          .doc('${user.uid}_${event.id}')
          .set({
            'userId': user.uid,
            'eventId': event.id,
            'eventTitle': event.title,
            'fullName': pick('fullName', user.displayName),
            'email': pick('email', user.email),
            'phone': pick('phone', user.phoneNumber),
            'college': pick('college', null),
            'studentId': pick('studentId', null),
            'registeredAt': FieldValue.serverTimestamp(),
          });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        // Rules refuse when registration closed or already registered.
        throw EventsFailure(
          'Could not register. Registration may be closed or you are already registered.',
          code: e.code,
        );
      }
      throw _map(e, 'Could not register for this event');
    }
  }

  EventsFailure _map(FirebaseException e, String fallback) {
    switch (e.code) {
      case 'permission-denied':
        return EventsFailure(
          'You do not have permission to do this',
          code: e.code,
        );
      case 'unavailable':
      case 'network-request-failed':
        return EventsFailure('No internet connection', code: e.code);
      default:
        return EventsFailure(fallback, code: e.code);
    }
  }
}
