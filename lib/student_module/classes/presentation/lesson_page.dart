import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/init_dependencies.dart'; // exports serviceLocator
import 'package:game_edu/student_module/classes/models/lesson_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/lesson_bloc.dart';
import '../models/lesson.dart';
import '../services/class_detail_service.dart';
import 'assignment_page.dart';
import 'lesson_video_page.dart';
import 'widgets/class_card.dart';
import 'widgets/class_labels.dart';
import 'widgets/gradient_header.dart';
import 'widgets/lesson_video.dart';
import 'widgets/lesson_widgets.dart';

/// One class page:
///   picture -> title -> About -> Lesson videos -> Study notes -> Assignment.
/// A video opens in its own page, the assignment opens in its own page.
class LessonPage extends StatelessWidget {
  const LessonPage({
    super.key,
    required this.classId,
    required this.lesson,
    required this.number,
    required this.videoDone,
    required this.result,
    this.thumbnailKey,
  });

  final String classId;
  final Lesson lesson;
  final int number;
  final bool videoDone;
  final AssignmentResult? result;

  /// Picture on top (the course thumbnail). Optional.
  final String? thumbnailKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonBloc>(
      create: (_) => LessonBloc(
        service: serviceLocator<ClassDetailService>(),
        classId: classId,
        lessonId: lesson.id,
        videoIds: lesson.playlist.map((v) => v.id).toList(),
        videoDone: videoDone,
        result: result,
      )..add(const LessonStarted()),
      child: _LessonView(
        lesson: lesson,
        number: number,
        thumbnailKey: thumbnailKey,
      ),
    );
  }
}

class _LessonView extends StatelessWidget {
  const _LessonView({
    required this.lesson,
    required this.number,
    required this.thumbnailKey,
  });

  final Lesson lesson;
  final int number;
  final String? thumbnailKey;

  void _show(ScaffoldMessengerState messenger, String text) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPalette.authTextPrimaryColor,
        ),
      );
  }

  void _openVideo(BuildContext context, List<LessonVideo> videos, int index) {
    final bloc = context.read<LessonBloc>();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<LessonBloc>.value(
          value: bloc,
          child: LessonVideoPage(
            video: videos[index],
            index: index,
            total: videos.length,
          ),
        ),
      ),
    );
  }

  void _openAssignment(BuildContext context) {
    final bloc = context.read<LessonBloc>();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<LessonBloc>.value(
          value: bloc,
          child: const AssignmentPage(),
        ),
      ),
    );
  }

  /// Opens / downloads a study material (PDF, doc ...) in the phone's viewer
  /// or browser.
  Future<void> _openMaterial(
    BuildContext context,
    LessonMaterial material,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final url = await LessonVideoSource.resolve(material.url);
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) _show(messenger, 'Could not open the file');
    } catch (_) {
      _show(messenger, 'Could not open the file');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final videos = lesson.playlist;
    final unit = kClassSingular.toLowerCase();

    return BlocListener<LessonBloc, LessonState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) =>
          _show(ScaffoldMessenger.of(context), state.message!),
      child: BlocListener<LessonBloc, LessonState>(
        // all videos just finished
        listenWhen: (p, c) => !p.videoDone && c.videoDone,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          _show(
            messenger,
            state.hasAssignment
                ? 'All videos completed! You can start the assignment now'
                : '$kClassSingular completed 🎉',
          );
        },
        child: BlocBuilder<LessonBloc, LessonState>(
          builder: (context, state) {
            final bloc = context.read<LessonBloc>();

            return Scaffold(
              backgroundColor: AppPalette.infoSurfaceColor,
              body: Column(
                children: [
                  GradientHeader(
                    title: '$kClassSingular $number',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        28 + bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (thumbnailKey != null) ...[
                            _Hero(thumbnailKey: thumbnailKey!),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            lesson.title.isEmpty
                                ? 'Untitled $unit'
                                : lesson.title,
                            style: const TextStyle(
                              fontSize: 28,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.authTextPrimaryColor,
                            ),
                          ),
                          if (lesson.description.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            LessonSectionTitle(title: 'About This $kClassSingular'),
                            const SizedBox(height: 6),
                            Text(
                              lesson.description,
                              style: const TextStyle(
                                fontSize: 15.5,
                                height: 1.4,
                                color: AppPalette.authTextSecondaryColor,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          LessonSectionTitle(
                            title: 'Lesson Videos',
                            trailing: videos.length > 1
                                ? '${state.watchedVideoIds.length}/${videos.length} watched'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _VideosCard(
                            videos: videos,
                            watched: state.watchedVideoIds,
                            onOpen: (i) => _openVideo(context, videos, i),
                          ),
                          const SizedBox(height: 20),
                          ..._lower(context, state, bloc),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Study notes + assignment (they need the extras loaded from Firestore).
  List<Widget> _lower(BuildContext context, LessonState state, LessonBloc bloc) {
    switch (state.status) {
      case LessonStatus.loading:
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];

      case LessonStatus.failure:
        return [
          LessonInfoCard(
            icon: Icons.cloud_off_outlined,
            title: state.error ?? 'Could not load this ${kClassSingular.toLowerCase()}',
            isError: true,
            actionLabel: 'Retry',
            onAction: () => bloc.add(const LessonStarted()),
          ),
        ];

      case LessonStatus.loaded:
        final hasNotes =
            lesson.takeaways.isNotEmpty || state.materials.isNotEmpty;

        return [
          if (hasNotes) ...[
            const LessonSectionTitle(title: 'Study Notes'),
            const SizedBox(height: 10),
            if (lesson.takeaways.isNotEmpty) ...[
              _TakeawaysCard(items: lesson.takeaways),
              const SizedBox(height: 12),
            ],
            for (final material in state.materials)
              _MaterialTile(
                material: material,
                onTap: () => _openMaterial(context, material),
              ),
            const SizedBox(height: 10),
          ],
          if (state.hasAssignment) ...[
            const LessonSectionTitle(title: 'Assignment'),
            const SizedBox(height: 10),
            _AssignmentCard(
              state: state,
              onOpen: () => _openAssignment(context),
            ),
          ],
        ];
    }
  }
}

// ───────────────────────── picture ─────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.thumbnailKey});

  final String thumbnailKey;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: ClassThumbTile(thumbnailKey: thumbnailKey, size: 400),
        ),
      ),
    );
  }
}

// ───────────────────────── videos ─────────────────────────

class _VideosCard extends StatelessWidget {
  const _VideosCard({
    required this.videos,
    required this.watched,
    required this.onOpen,
  });

  final List<LessonVideo> videos;
  final Set<String> watched;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const LessonInfoCard(
        icon: Icons.videocam_off_outlined,
        title: 'Video not added yet',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppPalette.inputBorderColor.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < videos.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: AppPalette.authDividerColor,
              ),
            _VideoRow(
              video: videos[i],
              watched: watched.contains(videos[i].id),
              onTap: () => onOpen(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoRow extends StatelessWidget {
  const _VideoRow({
    required this.video,
    required this.watched,
    required this.onTap,
  });

  final LessonVideo video;
  final bool watched;
  final VoidCallback onTap;

  Widget _placeholder() => const ColoredBox(
    color: Color(0xFF1B2A4A),
    child: SizedBox.expand(),
  );

  @override
  Widget build(BuildContext context) {
    final ytId = LessonVideoSource.youtubeId(video.url);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 108,
                height: 62,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (ytId != null)
                      Image.network(
                        'https://img.youtube.com/vi/$ytId/hqdefault.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    else
                      _placeholder(),
                    Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.45),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.authTextPrimaryColor,
                    ),
                  ),
                  if (video.durationLabel.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      video.durationLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppPalette.authTextSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              watched
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              size: watched ? 28 : 26,
              color: watched
                  ? AppPalette.successColor
                  : AppPalette.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── study notes ─────────────────────────

class _TakeawaysCard extends StatelessWidget {
  const _TakeawaysCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: AppPalette.primaryBlue.withValues(alpha: 0.10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: AppPalette.primaryBlue),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Key Takeaways',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.authTextPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppPalette.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    height: 1.35,
                                    color: AppPalette.authTextPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  const _MaterialTile({required this.material, required this.onTap});

  final LessonMaterial material;
  final VoidCallback onTap;

  IconData get _icon {
    switch (material.type) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
        return Icons.description_rounded;
      case 'ppt':
        return Icons.slideshow_rounded;
      case 'xls':
        return Icons.table_chart_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  String get _label {
    switch (material.type) {
      case 'pdf':
        return 'PDF';
      case 'doc':
        return 'Document';
      case 'ppt':
        return 'Presentation';
      case 'xls':
        return 'Spreadsheet';
      default:
        return 'Link';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppPalette.inputBorderColor.withValues(alpha: 0.7),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: [
                Icon(_icon, color: AppPalette.primaryBlue, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.authTextPrimaryColor,
                        ),
                      ),
                      Text(
                        _label,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppPalette.authTextSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.primaryBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── assignment card ─────────────────────────

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.state, required this.onOpen});

  final LessonState state;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final submitted = state.isSubmitted;
    final unlocked = state.videoDone;

    final String badge;
    final Color badgeColor;
    if (submitted) {
      badge = 'Completed';
      badgeColor = AppPalette.successColor;
    } else if (unlocked) {
      badge = 'Pending';
      badgeColor = AppPalette.primaryBlue;
    } else {
      badge = 'Locked';
      badgeColor = AppPalette.hintTextColor;
    }

    final String subtitle = submitted
        ? 'Score ${state.result!.score}/${state.result!.total}'
        : '${state.totalMarks} ${state.totalMarks == 1 ? 'mark' : 'marks'}';

    final String label = submitted
        ? 'View Result'
        : unlocked
        ? 'Start Assignment'
        : 'Watch all videos to unlock';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppPalette.inputBorderColor.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 38,
                color: AppPalette.primaryBlue,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Class Assignment',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.authTextPrimaryColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppPalette.authTextSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LessonPrimaryButton(
            label: label,
            enabled: unlocked || submitted,
            onTap: onOpen,
            trailingIcon: (unlocked || submitted)
                ? Icons.arrow_forward_rounded
                : Icons.lock_outline_rounded,
          ),
        ],
      ),
    );
  }
}