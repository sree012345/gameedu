import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:game_edu/core/config/server_config.dart';

class _Event {
  const _Event({
    required this.id,
    required this.title,
    required this.venue,
    required this.description,
    required this.category,
    required this.eventInDays,
    required this.eventHour,
    required this.registrationEndsInDays,
    this.eligibility = 'College students aged 18+',
    this.imageUrl = '',
  });

  final String id; // document id (same id again = overwrite, no duplicate)
  final String title;
  final String venue;
  final String description;
  final String eligibility;
  final String category; // racing, game_dev, hackathon, esports, art, workshop
  final String imageUrl; // optional photo link
  final int eventInDays; // event date = today + this many days
  final int eventHour; // IST hour of the event
  final int registrationEndsInDays; // registration ends today + N (negative = closed)
}

/// Dummy events for testing. Debug builds only.
/// Remove this file after the data is in Firestore.
class EventsSeed {
  EventsSeed._();

  static Future<void> run() async {
    if (!kDebugMode) return;

    final firestore = FirebaseFirestore.instance;
    final col = firestore.collection(ServerConfig.eventsCollection);

    // IST today
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

    // dayOffset days from today at hour:minute IST -> Timestamp
    Timestamp at(int dayOffset, int hour, int minute) {
      final ist = DateTime.utc(now.year, now.month, now.day + dayOffset, hour, minute);
      return Timestamp.fromDate(ist.subtract(const Duration(hours: 5, minutes: 30)));
    }

    // ─────────────── EDIT YOUR EVENTS HERE ───────────────
    const events = <_Event>[
      _Event(
        id: 'seed_event_01',
        title: 'Campus Sim Racing Challenge',
        venue: 'Game Edu Arena, Chennai',
        description: 'Compete in timed laps on a virtual circuit.',
        category: 'racing',
        eventInDays: 20,
        eventHour: 10,
        registrationEndsInDays: 14,
      ),
      _Event(
        id: 'seed_event_02',
        title: 'Game Dev Sprint',
        venue: 'Game Edu Lab, Chennai',
        description: 'Build a playable game prototype in one day.',
        category: 'game_dev',
        eventInDays: 27,
        eventHour: 9,
        registrationEndsInDays: 22,
      ),
      _Event(
        id: 'seed_event_03',
        title: 'Unity Hackathon',
        venue: 'Main Auditorium, Chennai',
        description: 'Team up and build a game around a surprise theme.',
        category: 'hackathon',
        eventInDays: 12,
        eventHour: 9,
        registrationEndsInDays: 8,
      ),
      _Event(
        id: 'seed_event_04',
        title: 'Pixel Art Jam',
        venue: 'Online',
        description: 'Create an original pixel art piece in 48 hours.',
        category: 'art',
        eventInDays: 9,
        eventHour: 18,
        registrationEndsInDays: 5,
        eligibility: 'Open to all students',
      ),
      // Registration already over -> shows "Registration Closed"
      _Event(
        id: 'seed_event_05',
        title: 'Esports Showdown',
        venue: 'Game Edu Arena, Chennai',
        description: 'Compete in a campus esports tournament.',
        category: 'esports',
        eventInDays: 3,
        eventHour: 11,
        registrationEndsInDays: -1,
      ),
      _Event(
        id: 'seed_event_06',
        title: 'Game Design Workshop',
        venue: 'Seminar Hall 2, Chennai',
        description: 'Learn to design levels, rules and rewards in a hands-on workshop.',
        category: 'workshop',
        eventInDays: 15,
        eventHour: 14,
        registrationEndsInDays: 12,
      ),
    ];
    // ───────────────────────────────────────────────────────

    final batch = firestore.batch();
    for (final e in events) {
      batch.set(col.doc(e.id), {
        'title': e.title,
        'venue': e.venue,
        'description': e.description,
        'eligibility': e.eligibility,
        'category': e.category,
        'imageUrl': e.imageUrl,
        'eventDate': at(e.eventInDays, e.eventHour, 0),
        // registration closes at 11:59 PM IST of that day
        'registrationEndsAt': at(e.registrationEndsInDays, 23, 59),
      });
    }
    await batch.commit();

    debugPrint('✅ [EventsSeed] ${events.length} events written');
  }
}
