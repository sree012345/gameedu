import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// One lesson of a class: `${env}_classes/{classId}/lessons/{lessonId}`.
class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.durationMinutes,
    required this.order,
  });

  final String id;
  final String title;
  final String description;

  /// YouTube link or any video link. Empty = not added yet.
  final String videoUrl;
  final int? durationMinutes;
  final int order;

  static String _s(Object? v) => (v ?? '').toString().trim();

  factory Lesson.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final order = d['order'];
    final minutes = d['durationMinutes'];

    return Lesson(
      id: doc.id,
      title: _s(d['title']),
      description: _s(d['description']),
      videoUrl: _s(d['videoUrl']),
      durationMinutes: minutes is num ? minutes.toInt() : null,
      order: order is num ? order.toInt() : 9999,
    );
  }

  /// true when [videoUrl] is a usable http(s) link.
  bool get hasVideo {
    final uri = Uri.tryParse(videoUrl);
    return uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    videoUrl,
    durationMinutes,
    order,
  ];
}
