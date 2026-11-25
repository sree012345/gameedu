import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';

import '../bloc/lesson_bloc.dart';
import '../models/lesson.dart';
import 'widgets/class_card.dart';
import 'widgets/gradient_header.dart';
import 'widgets/lesson_player_page.dart';

/// Plays ONE video of a class. Open it with the SAME LessonBloc as the
/// class page:
///
///   BlocProvider<LessonBloc>.value(value: bloc, child: LessonVideoPage(...))
class LessonVideoPage extends StatelessWidget {
  const LessonVideoPage({
    super.key,
    required this.video,
    required this.index,
    required this.total,
  });

  final LessonVideo video;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LessonBloc>();

    // The player only needs a Lesson with the link of THIS video.
    final asLesson = Lesson(
      id: video.id,
      title: video.title,
      description: '',
      videoUrl: video.url,
      durationMinutes: null,
      order: index,
      
    );

    return LessonVideoPlayer(
      key: ValueKey(video.id),
      lesson: asLesson,
      onCompleted: () => bloc.add(LessonVideoWatched(video.id)),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppPalette.infoSurfaceColor,
          body: Column(
            children: [
              GradientHeader(
                title: 'Video ${index + 1} of $total',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ColoredBox(color: Colors.black, child: player),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          28 + MediaQuery.of(context).padding.bottom,
                        ),
                        child: _TitleCard(video: video),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.video});

  final LessonVideo video;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonBloc, LessonState>(
      buildWhen: (p, c) => p.watchedVideoIds != c.watchedVideoIds,
      builder: (context, state) {
        final watched = state.watchedVideoIds.contains(video.id);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppPalette.authCardSurfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: classCardShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.authTextPrimaryColor,
                ),
              ),
              if (video.durationLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  video.durationLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppPalette.authTextSecondaryColor,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    watched
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_outline_rounded,
                    size: 18,
                    color: watched
                        ? AppPalette.successColor
                        : AppPalette.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      watched
                          ? 'Watched'
                          : 'Watch the full video to mark it as watched',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: watched
                            ? AppPalette.successColor
                            : AppPalette.authTextSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}