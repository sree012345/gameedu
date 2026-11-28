import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../community_theme.dart';

/// Compact audio player. All playback state comes from the player's streams,
/// so no `setState` is needed.
class AudioMessagePlayer extends StatefulWidget {
  const AudioMessagePlayer({
    super.key,
    required this.url,
    this.color = CommunityColors.primary,
  });

  final String url;
  final Color color;

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(PlayerState state) async {
    switch (state) {
      case PlayerState.playing:
        await _player.pause();
      case PlayerState.paused:
        await _player.resume();
      default:
        await _player.play(UrlSource(widget.url));
    }
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _player.onPlayerStateChanged,
      initialData: _player.state,
      builder: (context, stateSnap) {
        final playerState = stateSnap.data ?? PlayerState.stopped;
        final playing = playerState == PlayerState.playing;

        return StreamBuilder<Duration>(
          stream: _player.onDurationChanged,
          builder: (context, durSnap) {
            final total = durSnap.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _player.onPositionChanged,
              builder: (context, posSnap) {
                final position = posSnap.data ?? Duration.zero;
                final progress = total.inMilliseconds == 0
                    ? 0.0
                    : (position.inMilliseconds / total.inMilliseconds)
                        .clamp(0.0, 1.0);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _toggle(playerState),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          playing
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: widget.color,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            color: widget.color,
                            backgroundColor: widget.color.withOpacity(0.25),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            total == Duration.zero
                                ? 'Audio'
                                : '${_format(position)} / ${_format(total)}',
                            style: TextStyle(
                              color: widget.color.withOpacity(0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
