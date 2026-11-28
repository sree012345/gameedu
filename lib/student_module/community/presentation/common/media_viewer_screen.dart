import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/community_message.dart';
import '../community_theme.dart';
import '../widgets/audio_message_player.dart';

/// Full-screen viewer for an image, video or audio message.
class MediaViewerScreen extends StatelessWidget {
  const MediaViewerScreen({super.key, required this.message});

  final CommunityMessage message;

  @override
  Widget build(BuildContext context) {
    final url = message.mediaUrl ?? '';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          message.senderName,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: switch (message.type) {
            CommunityMessageType.image => InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const CircularProgressIndicator(),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            CommunityMessageType.video => _VideoViewer(url: url),
            CommunityMessageType.audio => Padding(
                padding: const EdgeInsets.all(32),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.audiotrack_rounded,
                          size: 48, color: CommunityColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        message.fileName ?? 'Audio',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CommunityColors.title,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AudioMessagePlayer(url: url),
                    ],
                  ),
                ),
              ),
            CommunityMessageType.text => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  const _VideoViewer({required this.url});

  final String url;

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialized;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initialized = _controller.initialize().then((_) => _controller.play());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialized,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Could not play this video.',
            style: TextStyle(color: Colors.white70),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            const SizedBox(height: 8),
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: CommunityColors.primaryLight,
              ),
            ),
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller,
              builder: (context, value, _) => IconButton(
                iconSize: 48,
                color: Colors.white,
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                ),
                onPressed: () =>
                    value.isPlaying ? _controller.pause() : _controller.play(),
              ),
            ),
          ],
        );
      },
    );
  }
}
