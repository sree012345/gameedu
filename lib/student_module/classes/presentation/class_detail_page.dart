import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/init_dependencies.dart'; // exports serviceLocator
import 'package:game_edu/student_module/classes/models/lesson_model.dart';

import '../bloc/class_detail_bloc.dart';
import '../models/class_item.dart';
import '../models/lesson.dart';
import '../services/class_detail_service.dart';
import 'lesson_page.dart';
import 'widgets/class_card.dart';
import 'widgets/class_formatters.dart';
import 'widgets/class_labels.dart';
import 'widgets/gradient_header.dart';

/// Class detail: info + the list of classes (lessons).
/// Tapping a class opens its own page (video, materials, assignment).
/// A class unlocks only after the previous one is done
/// (video watched + assignment submitted, if it has one).
class ClassDetailPage extends StatelessWidget {
  const ClassDetailPage({super.key, required this.item});

  final ClassItem item;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClassDetailBloc>(
      create: (_) => ClassDetailBloc(
        service: serviceLocator<ClassDetailService>(),
        classId: item.id,
      )..add(const ClassDetailStarted()),
      child: _ClassDetailView(item: item),
    );
  }
}

class _ClassDetailView extends StatelessWidget {
  const _ClassDetailView({required this.item});

  final ClassItem item;

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPalette.authTextPrimaryColor,
        ),
      );
  }

  /// Opens the class page (if unlocked) and refreshes progress on return.
  Future<void> _openLesson(
    BuildContext context,
    int index,
    ClassDetailState state,
  ) async {
    final lesson = state.lessons[index];

    if (!state.isUnlocked(index)) {
      _snack(
        context,
        'Finish $kClassSingular $index to unlock this ${kClassSingular.toLowerCase()}',
      );
      return;
    }

    if (!lesson.hasVideo) {
      _snack(context, 'Video link not added yet');
      return;
    }

    final bloc = context.read<ClassDetailBloc>();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonPage(
          classId: item.id,
          lesson: lesson,
          number: index + 1,
          videoDone: state.completedIds.contains(lesson.id),
          result: state.userProgress.results[lesson.id],
        ),
      ),
    );

    if (!bloc.isClosed) bloc.add(const ClassDetailRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassDetailBloc, ClassDetailState>(
      builder: (context, state) {
        final bloc = context.read<ClassDetailBloc>();

        return Scaffold(
          backgroundColor: AppPalette.infoSurfaceColor,
          bottomNavigationBar:
              state.status == ClassDetailStatus.loaded && state.total > 0
              ? _ProgressBar(state: state)
              : null,
          body: Column(
            children: [
              GradientHeader(
                title: 'Class Details',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Overview(item: item),
                      const SizedBox(height: 22),
                      _ClassesSection(
                        state: state,
                        onRetry: () => bloc.add(const ClassDetailStarted()),
                        onOpen: (index) => _openLesson(context, index, state),
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

// ───────────────────────── overview ─────────────────────────

class _Overview extends StatelessWidget {
  const _Overview({required this.item});

  final ClassItem item;

  @override
  Widget build(BuildContext context) {
    final status = item.statusAt(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: classCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClassThumbTile(thumbnailKey: item.thumbnailKey, size: 80),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.authTextPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      switch (status) {
                        ClassStatus.live => 'Live now',
                        ClassStatus.upcoming => 'Upcoming',
                        ClassStatus.ended => 'Ended',
                      },
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: status == ClassStatus.live
                            ? AppPalette.errorText
                            : AppPalette.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.description.isEmpty
                ? 'No description added yet.'
                : item.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppPalette.authTextSecondaryColor,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppPalette.authDividerColor),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Mentor',
            value: item.mentorName.isEmpty ? '-' : item.mentorName,
          ),
          _InfoRow(
            icon: Icons.sell_outlined,
            label: 'Topic',
            value: item.topicLabel.isEmpty ? '-' : item.topicLabel,
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: formatDate(item.startsAt),
          ),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Time (IST)',
            value:
                '${formatRange(item.startsAt, item.endsAt)} · ${formatDuration(item.duration)}',
          ),
          _InfoRow(
            icon: Icons.groups_outlined,
            label: 'Open to',
            value: item.isGeneral
                ? 'Everyone'
                : '${item.college ?? 'College'} students only',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppPalette.primaryBlue),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppPalette.authTextSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── classes list ─────────────────────────

class _ClassesSection extends StatelessWidget {
  const _ClassesSection({
    required this.state,
    required this.onRetry,
    required this.onOpen,
  });

  final ClassDetailState state;
  final VoidCallback onRetry;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (state.status) {
      case ClassDetailStatus.loading:
        body = const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      case ClassDetailStatus.failure:
        body = _InfoCard(
          icon: Icons.cloud_off_outlined,
          title: state.error ?? 'Could not load classes',
          isError: true,
          actionLabel: 'Retry',
          onAction: onRetry,
        );
      case ClassDetailStatus.loaded:
        if (state.lessons.isEmpty) {
          body = _InfoCard(
            icon: Icons.video_library_outlined,
            title: '$kClassPlural coming soon',
            subtitle: '$kClassPlural for this course will be added here.',
          );
        } else {
          body = Column(
            children: [
              for (int i = 0; i < state.lessons.length; i++)
                _ClassTile(
                  number: i + 1,
                  lesson: state.lessons[i],
                  done: state.isLessonDone(state.lessons[i]),
                  videoDone: state.completedIds.contains(state.lessons[i].id),
                  hasAssignment: state.hasAssignment(state.lessons[i]),
                  result: state.userProgress.results[state.lessons[i].id],
                  locked: !state.isUnlocked(i),
                  onOpen: () => onOpen(i),
                ),
            ],
          );
        }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                kClassPlural,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.authTextPrimaryColor,
                ),
              ),
            ),
            if (state.status == ClassDetailStatus.loaded && state.total > 0)
              Text(
                '${state.total} ${state.total == 1 ? kClassSingular.toLowerCase() : kClassPlural.toLowerCase()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.authTextSecondaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        body,
      ],
    );
  }
}

class _ClassTile extends StatelessWidget {
  const _ClassTile({
    required this.number,
    required this.lesson,
    required this.done,
    required this.videoDone,
    required this.hasAssignment,
    required this.result,
    required this.locked,
    required this.onOpen,
  });

  final int number;
  final Lesson lesson;
  final bool done;
  final bool videoDone;
  final bool hasAssignment;
  final AssignmentResult? result;
  final bool locked;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final hasVideo = lesson.hasVideo;
    final playable = hasVideo && !locked;
    final assignmentPending = videoDone && hasAssignment && !done;

    final String subtitle;
    if (locked) {
      subtitle = 'Locked · finish $kClassSingular ${number - 1} first';
    } else if (result != null) {
      subtitle = 'Completed · Score ${result!.score}/${result!.total}';
    } else if (done) {
      subtitle = 'Completed';
    } else if (assignmentPending) {
      subtitle = 'Assignment pending';
    } else {
      subtitle = [
        if (lesson.durationMinutes != null) '${lesson.durationMinutes} min',
        hasVideo ? 'Video' : 'Video not added yet',
      ].join(' · ');
    }

    final Color borderColor = done
        ? AppPalette.successColor.withValues(alpha: 0.5)
        : assignmentPending
        ? AppPalette.primaryBlue.withValues(alpha: 0.5)
        : Colors.transparent;

    return Opacity(
      opacity: locked ? 0.6 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppPalette.authCardSurfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: classCardShadow(),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  // play / lock button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: playable
                          ? AppPalette.primaryBlue.withValues(alpha: 0.12)
                          : AppPalette.inputBorderColor.withValues(alpha: 0.5),
                    ),
                    child: Icon(
                      locked
                          ? Icons.lock_rounded
                          : !hasVideo
                          ? Icons.videocam_off_outlined
                          : Icons.play_arrow_rounded,
                      size: playable ? 30 : 22,
                      color: playable
                          ? AppPalette.primaryBlue
                          : AppPalette.hintTextColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$kClassSingular $number',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lesson.title.isEmpty
                              ? 'Untitled ${kClassSingular.toLowerCase()}'
                              : lesson.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.authTextPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              locked
                                  ? Icons.lock_outline_rounded
                                  : assignmentPending
                                  ? Icons.assignment_outlined
                                  : Icons.schedule_rounded,
                              size: 15,
                              color: AppPalette.authTextSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: playable
                                      ? AppPalette.authTextSecondaryColor
                                      : AppPalette.hintTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    done
                        ? Icons.check_circle_rounded
                        : locked
                        ? Icons.lock_outline_rounded
                        : assignmentPending
                        ? Icons.assignment_late_outlined
                        : Icons.chevron_right_rounded,
                    size: 26,
                    color: done
                        ? AppPalette.successColor
                        : assignmentPending
                        ? AppPalette.primaryBlue
                        : AppPalette.inputBorderColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── progress (bottom) ─────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.state});

  final ClassDetailState state;

  @override
  Widget build(BuildContext context) {
    final done = state.isComplete;
    final color = done ? AppPalette.successColor : AppPalette.primaryBlue;

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.buttonShadowColor.withValues(alpha: 0.9),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Your progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.authTextPrimaryColor,
                      ),
                    ),
                  ),
                  Text(
                    '${state.completedCount} of ${state.total} ${kClassPlural.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.authTextSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: state.progress),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: AppPalette.inputBorderColor.withValues(
                      alpha: 0.6,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (done) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppPalette.successColor,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    done
                        ? 'All ${kClassPlural.toLowerCase()} completed'
                        : '${state.percent}% completed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isError = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: classCardShadow(),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppPalette.primaryBlue),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isError
                  ? AppPalette.errorText
                  : AppPalette.authTextPrimaryColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppPalette.authTextSecondaryColor,
              ),
            ),
          ],
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}