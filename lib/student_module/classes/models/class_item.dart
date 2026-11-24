import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ClassStatus { live, upcoming, ended }

/// One document of the classes collection.
class ClassItem extends Equatable {
  const ClassItem({
    required this.id,
    required this.title,
    required this.description,
    required this.mentorName,
    required this.topic,
    required this.audience,
    required this.college,
    required this.startsAt,
    required this.endsAt,
    required this.thumbnailKey,
  });

  final String id;
  final String title;
  final String description;
  final String mentorName;

  /// e.g. `track_design`
  final String topic;

  /// `general` or a college-only audience.
  final String audience;

  /// null for General, a college code (e.g. `RGI`) for a college class.
  final String? college;

  final DateTime startsAt;
  final DateTime endsAt;
  final String thumbnailKey;

  static String _s(Object? v) => (v ?? '').toString().trim();

  /// Returns null when the document has no valid start / end time.
  static ClassItem? tryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return null;

    final starts = d['startsAt'];
    final ends = d['endsAt'];
    if (starts is! Timestamp || ends is! Timestamp) return null;

    final college = _s(d['college']);

    return ClassItem(
      id: doc.id,
      title: _s(d['title']),
      description: _s(d['description']),
      mentorName: _s(d['mentorName']),
      topic: _s(d['topic']),
      audience: _s(d['audience']).isEmpty ? 'general' : _s(d['audience']),
      college: college.isEmpty ? null : college,
      startsAt: starts.toDate(),
      endsAt: ends.toDate(),
      thumbnailKey: _s(d['thumbnailKey']),
    );
  }

  bool get isGeneral => audience.toLowerCase() == 'general';

  Duration get duration => endsAt.difference(startsAt);

  /// "track_design" -> "Track Design"
  String get topicLabel => topicToLabel(topic);

  static String topicToLabel(String topic) {
    return topic
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  ClassStatus statusAt(DateTime now) {
    if (now.isBefore(startsAt)) return ClassStatus.upcoming;
    if (now.isBefore(endsAt)) return ClassStatus.live;
    return ClassStatus.ended;
  }

  /// General classes are for everyone. College classes are only for users
  /// of that college (compared ignoring case).
  bool isVisibleTo(String userCollege) {
    if (isGeneral) return true;
    final c = college?.trim().toLowerCase();
    return c != null && c.isNotEmpty && c == userCollege.trim().toLowerCase();
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    mentorName,
    topic,
    audience,
    college,
    startsAt,
    endsAt,
    thumbnailKey,
  ];
}
