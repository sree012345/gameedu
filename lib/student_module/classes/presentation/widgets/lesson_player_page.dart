import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/student_module/classes/models/lesson.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'lesson_video.dart';

/// Builds the whole screen. [player] is the 16:9 video box to place in it.
typedef LessonScreenBuilder =
    Widget Function(BuildContext context, Widget player);

/// Plays a lesson video and builds the WHOLE screen around it.
///
///  * YouTube links      -> youtube_player_flutter (Android / iOS)
///  * mp4 / https links  -> video_player + chewie (Android / iOS / web)
///  * Firebase Storage   -> video_player + chewie (Android / iOS / web)
///
/// The video does NOT start automatically: the student taps play.
///
/// YouTube fullscreen is handled HERE (own button + explicit orientation
/// lock). We do not use YoutubePlayerBuilder, because its automatic
/// rotation detection fights with the orientation lock and flips the screen
/// between portrait and landscape again and again.
///
/// [onCompleted] is called when the video reaches the end.
///
/// Give it `key: ValueKey(lesson.id)` so a new player is created whenever the
/// lesson changes.
class LessonVideoPlayer extends StatefulWidget {
  const LessonVideoPlayer({
    super.key,
    required this.lesson,
    required this.onCompleted,
    required this.builder,
  });

  final Lesson lesson;
  final VoidCallback onCompleted;
  final LessonScreenBuilder builder;

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  YoutubePlayerController? _yt;
  VideoPlayerController? _video;
  ChewieController? _chewie;

  // Keeps the YouTube player (and its web view) alive when it moves between
  // the normal page and the fullscreen layout.
  GlobalKey _ytKey = GlobalKey();
  String? _ytId;

  bool _reported = false;
  bool _loading = true;
  bool _fullscreen = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final raw = widget.lesson.videoUrl;

    try {
      final ytId = LessonVideoSource.youtubeId(raw);

      if (ytId != null) {
        if (kIsWeb) {
          _error = 'YouTube videos play on the mobile app only.\n'
              'Please use the Android / iOS app.';
        } else {
          _ytId = ytId;
          _yt = YoutubePlayerController(
            initialVideoId: ytId,
            flags: const YoutubePlayerFlags(
              autoPlay: false, // starts only when the user taps play
              mute: false,
              enableCaption: false,
            ),
          )..addListener(_onYoutube);
        }
      } else {
        final url = await LessonVideoSource.resolve(raw);
        final controller = VideoPlayerController.networkUrl(Uri.parse(url));
        await controller.initialize();

        // Page / lesson changed while the video was loading.
        if (!mounted) {
          await controller.dispose();
          return;
        }

        controller.addListener(_onVideo);
        _video = controller;
        _chewie = ChewieController(
          videoPlayerController: controller,
          autoPlay: false, // starts only when the user taps play
          aspectRatio: controller.value.aspectRatio,
          allowFullScreen: true,
          allowMuting: true,
          // fullscreen = landscape, back = portrait
          deviceOrientationsOnEnterFullScreen: const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
          deviceOrientationsAfterFullScreen: const [
            DeviceOrientation.portraitUp,
          ],
        );
      }
    } catch (_) {
      _error = 'Could not load the video';
    }

    if (mounted) setState(() => _loading = false);
  }

  void _onYoutube() {
    final c = _yt;
    if (c == null) return;

    if (c.value.hasError) {
      if (mounted && _error == null) {
        setState(() => _error = 'This YouTube video cannot be played here');
      }
      return;
    }

    if (c.value.playerState == PlayerState.ended) _markDone();
  }

  void _onVideo() {
    final v = _video?.value;
    if (v == null || !v.isInitialized) return;

    final total = v.duration;
    if (total > Duration.zero &&
        v.position >= total - const Duration(milliseconds: 500)) {
      _markDone();
    }
  }

  void _markDone() {
    if (_reported) return;
    _reported = true;
    widget.onCompleted();
  }

  /// Our own fullscreen: lock landscape + hide bars, or lock portrait + show
  /// bars. No automatic rotation detection, so nothing can flip back.
  void _setFullscreen(bool value) {
    if (_fullscreen == value) return;

    if (value) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }

    setState(() {
      _fullscreen = value;
      // Back to portrait: the web view is broken after moving between the
      // two layouts, so start a fresh player at the same position.
      if (!value) _recreateYoutube();
    });
  }

  void _recreateYoutube() {
    final old = _yt;
    final id = _ytId;
    if (old == null || id == null) return;

    final position = old.value.position;
    final wasPlaying = old.value.isPlaying;

    old.removeListener(_onYoutube);

    _yt = YoutubePlayerController(
      initialVideoId: id,
      flags: YoutubePlayerFlags(
        autoPlay: wasPlaying,
        startAt: position.inSeconds,
        mute: false,
        enableCaption: false,
      ),
    )..addListener(_onYoutube);
    _ytKey = GlobalKey(); // brand new player widget

    // Dispose the old controller after the frame that stops using it.
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void dispose() {
    _yt?.removeListener(_onYoutube);
    _yt?.dispose();
    _video?.removeListener(_onVideo);
    _chewie?.dispose();
    _video?.dispose();

    // Never leave the app stuck in landscape / hidden status bar.
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  /// The 16:9 black box that holds the video.
  Widget _frame(Widget child) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(color: Colors.black, child: child),
    );
  }

  Widget _youtubePlayer() {
    return YoutubePlayer(
      key: _ytKey,
      controller: _yt!,
      aspectRatio: 16 / 9,
      showVideoProgressIndicator: true,
      progressIndicatorColor: AppPalette.primaryBlue,
      // Same as the default bar, but with OUR fullscreen button.
      bottomActions: [
        const SizedBox(width: 8),
        CurrentPosition(),
        const SizedBox(width: 8),
        ProgressBar(
          isExpanded: true,
          colors: ProgressBarColors(
            playedColor: AppPalette.primaryBlue,
            handleColor: AppPalette.primaryBlue,
          ),
        ),
        RemainingDuration(),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(
            _fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white,
          ),
          onPressed: () => _setFullscreen(!_fullscreen),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // YouTube.
    if (_yt != null && !_loading && _error == null) {
      final player = _youtubePlayer();

      if (_fullscreen) {
        // Landscape: only the video, back button leaves fullscreen.
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _setFullscreen(false);
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: AspectRatio(aspectRatio: 16 / 9, child: player),
            ),
          ),
        );
      }

      return widget.builder(context, _frame(player));
    }

    // Loading / error / mp4 + Firebase videos.
    Widget child;

    if (_loading) {
      child = const Center(
        child: CircularProgressIndicator(color: AppPalette.white),
      );
    } else if (_error != null) {
      child = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppPalette.white, fontSize: 14),
          ),
        ),
      );
    } else {
      child = Chewie(controller: _chewie!);
    }

    return widget.builder(context, _frame(child));
  }
}