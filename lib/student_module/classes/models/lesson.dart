import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

String _text(Object? v) => (v ?? '').toString().trim();

/// One video inside a lesson (class).
///
/// Stored in the lesson doc as an array field `videos`:
///   [ { id: "video_01", title: "Track Layout Overview",
///       url: "https://youtu.be/...", durationSeconds: 522,
///       thumbnailUrl: "https://.../picture.jpg" } ]
class LessonVideo extends Equatable {
  const LessonVideo({
    required this.id,
    required this.title,
    required this.url,
    this.durationSeconds,
    this.thumbnailUrl = '',
  });

  final String id;
  final String title;
  final String url;
  final int? durationSeconds;

  /// Picture shown in the video list (any https image link).
  /// Empty = YouTube thumbnail (for YouTube links) or a dark placeholder.
  final String thumbnailUrl;

  /// true when [url] is a usable http(s) link.
  bool get isValid {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
  }

  /// 522 -> "8:42"
  String get durationLabel {
    final s = durationSeconds;
    if (s == null || s <= 0) return '';
    final m = s ~/ 60;
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  factory LessonVideo.fromMap(Map<String, dynamic> map, int index) {
    final seconds = map['durationSeconds'];
    final id = _text(map['id']);
    final title = _text(map['title']);

    return LessonVideo(
      id: id.isEmpty ? 'video_${index + 1}' : id,
      title: title.isEmpty ? 'Video ${index + 1}' : title,
      url: _text(map['url']),
      durationSeconds: seconds is num ? seconds.toInt() : null,
      thumbnailUrl: _text(map['thumbnailUrl']),
    );
  }

  @override
  List<Object?> get props => [id, title, url, durationSeconds, thumbnailUrl];
}

/// One lesson (class page) of a course:
/// `${env}_classes/{classId}/lessons/{lessonId}`.
class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.durationMinutes,
    required this.order,
    this.videos = const <LessonVideo>[],
    this.takeaways = const <String>[],
    this.imageUrl = '',
  });

  final String id;
  final String title;
  final String description;

  /// Old single-video field. Used only when [videos] is empty.
  final String videoUrl;
  final int? durationMinutes;
  final int order;

  /// The lesson videos (Firestore array `videos`).
  final List<LessonVideo> videos;

  /// "Key takeaways" bullets (Firestore array `keyTakeaways`).
  final List<String> takeaways;

  /// Picture at the top of the class page (Firestore text field `imageUrl`).
  /// Empty = the course thumbnail is used.
  final String imageUrl;

  factory Lesson.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final order = d['order'];
    final minutes = d['durationMinutes'];

    final rawVideos = d['videos'];
    final videos = <LessonVideo>[];
    if (rawVideos is List) {
      for (var i = 0; i < rawVideos.length; i++) {
        final item = rawVideos[i];
        if (item is Map) {
          videos.add(LessonVideo.fromMap(Map<String, dynamic>.from(item), i));
        }
      }
    }

    final rawTakeaways = d['keyTakeaways'];
    final takeaways = rawTakeaways is List
        ? rawTakeaways.map(_text).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return Lesson(
      id: doc.id,
      title: _text(d['title']),
      description: _text(d['description']),
      videoUrl: _text(d['videoUrl']),
      durationMinutes: minutes is num ? minutes.toInt() : null,
      order: order is num ? order.toInt() : 9999,
      videos: videos,
      takeaways: takeaways,
      imageUrl: _text(d['imageUrl']),
    );
  }

  /// The videos to show: the `videos` array, or (old data) the single
  /// `videoUrl` as one video.
  List<LessonVideo> get playlist {
    final list = videos.where((v) => v.isValid).toList();
    if (list.isNotEmpty) return list;

    final legacy = LessonVideo(
      id: '${id}_video', // the lesson's own id, no fixed text
      title: title.isEmpty ? 'Lesson video' : title,
      url: videoUrl,
      durationSeconds: durationMinutes == null ? null : durationMinutes! * 60,
    );
    return legacy.isValid ? [legacy] : const <LessonVideo>[];
  }

  /// true when the lesson has at least one playable video.
  bool get hasVideo => playlist.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    videoUrl,
    durationMinutes,
    order,
    videos,
    takeaways,
    imageUrl,
  ];
}