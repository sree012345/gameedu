import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// One document of the events collection (`${env}_events/{eventId}`).
class EventItem extends Equatable {
  const EventItem({
    required this.id,
    required this.title,
    required this.venue,
    required this.description,
    required this.eligibility,
    required this.eventDate,
    required this.registrationEndsAt,
    required this.imageUrl,
    required this.category,
  });

  final String id;
  final String title;
  final String venue;
  final String description;

  /// e.g. "College students aged 18+"
  final String eligibility;
  final DateTime eventDate;
  final DateTime registrationEndsAt;

  /// Optional photo link. Empty -> a coloured icon tile is shown.
  final String imageUrl;

  /// e.g. racing, game_dev, hackathon, esports (icon + colour of the tile)
  final String category;

  static String _s(Object? v) => (v ?? '').toString().trim();

  /// Returns null when the document has no valid dates.
  static EventItem? tryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return null;

    final eventDate = d['eventDate'];
    final regEnds = d['registrationEndsAt'];
    if (eventDate is! Timestamp || regEnds is! Timestamp) return null;

    return EventItem(
      id: doc.id,
      title: _s(d['title']),
      venue: _s(d['venue']),
      description: _s(d['description']),
      eligibility: _s(d['eligibility']),
      eventDate: eventDate.toDate(),
      registrationEndsAt: regEnds.toDate(),
      imageUrl: _s(d['imageUrl']),
      category: _s(d['category']),
    );
  }

  bool isRegistrationOpen(DateTime now) => now.isBefore(registrationEndsAt);

  @override
  List<Object?> get props => [
    id,
    title,
    venue,
    description,
    eligibility,
    eventDate,
    registrationEndsAt,
    imageUrl,
    category,
  ];
}
