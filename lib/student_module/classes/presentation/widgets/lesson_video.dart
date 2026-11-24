import 'package:firebase_storage/firebase_storage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Works out what kind of video a lesson has.
///
/// `videoUrl` in the lesson doc can be:
///  * a YouTube link        -> plays in the in-app YouTube player (mobile)
///  * an https video link   -> plays in the in-app video player (use mp4)
///  * `gs://bucket/path`    -> Firebase Storage, resolved to a download url
///  * `videos/c1/l1.mp4`    -> Firebase Storage path, resolved to a download url
class LessonVideoSource {
  const LessonVideoSource._();

  static String? youtubeId(String url) => YoutubePlayer.convertUrlToId(url);

  static bool isYoutube(String url) => youtubeId(url) != null;

  /// Returns a playable https url (resolves Firebase Storage paths).
  static Future<String> resolve(String raw) async {
    final url = raw.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final storage = FirebaseStorage.instance;
    final ref = url.startsWith('gs://')
        ? storage.refFromURL(url)
        : storage.ref(url);
    return ref.getDownloadURL();
  }
}