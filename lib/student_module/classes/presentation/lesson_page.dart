import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/init_dependencies.dart'; // exports serviceLocator
import 'package:game_edu/student_module/classes/models/lesson_model.dart';
import 'package:game_edu/student_module/classes/presentation/widgets/gradient_header.dart';
import 'package:game_edu/student_module/classes/presentation/widgets/lesson_player_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/lesson_bloc.dart';
import '../models/lesson.dart';
import '../services/class_detail_service.dart';
import 'widgets/class_card.dart';
import 'widgets/class_labels.dart';
import 'widgets/lesson_video.dart';

/// One class (lesson) page:
///   video (top)  ->  study materials (tap = open / download)
///   ->  assignment (opens when the video ends, multiple choice, marks saved).
class LessonPage extends StatelessWidget {
  const LessonPage({
    super.key,
    required this.classId,
    required this.lesson,
    required this.number,
    required this.videoDone,
    required this.result,
  });

  final String classId;
  final Lesson lesson;
  final int number;
  final bool videoDone;
  final AssignmentResult? result;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonBloc>(
      create: (_) => LessonBloc(
        service: serviceLocator<ClassDetailService>(),
        classId: classId,
        lessonId: lesson.id,
        videoDone: videoDone,
        result: result,
      )..add(const LessonStarted()),
      child: _LessonView(lesson: lesson, number: number),
    );
  }
}

class _LessonView extends StatefulWidget {
  const _LessonView({required this.lesson, required this.number});

  final Lesson lesson;
  final int number;

  @override
  State<_LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<_LessonView> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _assignmentKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

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

  void _scrollToAssignment() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _assignmentKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  /// Opens / downloads a study material (PDF, doc ...) in the phone's viewer
  /// or browser.
  Future<void> _openMaterial(LessonMaterial material) async {
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

  Future<void> _confirmSubmit(LessonBloc bloc, LessonState state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit assignment?'),
        content: Text(
          'You answered ${state.answeredCount} of ${state.questions.length} '
          'questions. You cannot change your answers after submitting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) bloc.add(const AssignmentSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final unit = kClassSingular.toLowerCase();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return BlocListener<LessonBloc, LessonState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) =>
          _show(ScaffoldMessenger.of(context), state.message!),
      child: BlocListener<LessonBloc, LessonState>(
        // assignment just submitted -> scroll up to the score card
        listenWhen: (p, c) => !p.isSubmitted && c.isSubmitted,
        listener: (context, state) => _scrollToAssignment(),
        child: BlocListener<LessonBloc, LessonState>(
          // video just finished
          listenWhen: (p, c) => !p.videoDone && c.videoDone,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            if (state.hasAssignment) {
              _show(messenger, 'Video completed! Now do the assignment');
              _scrollToAssignment();
            } else {
              _show(messenger, '${kClassSingular} completed 🎉');
            }
          },
          child: BlocBuilder<LessonBloc, LessonState>(
            builder: (context, state) {
              final bloc = context.read<LessonBloc>();

              // The player wraps the whole screen (needed for YouTube
              // fullscreen / landscape): in landscape it shows only the video.
              return LessonVideoPlayer(
                key: ValueKey(widget.lesson.id),
                lesson: widget.lesson,
                onCompleted: () => bloc.add(const LessonVideoFinished()),
                builder: (context, player) {
                  return Scaffold(
                    backgroundColor: AppPalette.infoSurfaceColor,
                    body: Column(
                      children: [
                        GradientHeader(
                          title: '$kClassSingular ${widget.number}',
                          onBack: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scroll,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // the video now scrolls together with the page
                                ColoredBox(color: Colors.black, child: player),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    28 + bottomInset,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _TitleCard(
                                        number: widget.number,
                                        lesson: widget.lesson,
                                        state: state,
                                        unit: unit,
                                      ),
                                      const SizedBox(height: 18),
                                      ..._body(context, state, bloc),
                                    ],
                                  ),
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
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, LessonState state, LessonBloc bloc) {
    switch (state.status) {
      case LessonStatus.loading:
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];

      case LessonStatus.failure:
        return [
          _InfoCard(
            icon: Icons.cloud_off_outlined,
            title: state.error ?? 'Could not load this ${kClassSingular.toLowerCase()}',
            isError: true,
            actionLabel: 'Retry',
            onAction: () => bloc.add(const LessonStarted()),
          ),
        ];

      case LessonStatus.loaded:
        return [
          if (state.materials.isNotEmpty) ...[
            const _SectionTitle(title: 'Study materials'),
            const SizedBox(height: 10),
            for (final material in state.materials)
              _MaterialTile(
                material: material,
                onTap: () => _openMaterial(material),
              ),
            const SizedBox(height: 18),
          ],
          KeyedSubtree(
            key: _assignmentKey,
            child: _AssignmentSection(
              state: state,
              onSelect: (questionId, index) =>
                  bloc.add(AnswerSelected(questionId, index)),
              onSubmit: () => _confirmSubmit(bloc, state),
            ),
          ),
        ];
    }
  }
}

// ───────────────────────── title ─────────────────────────

class _TitleCard extends StatelessWidget {
  const _TitleCard({
    required this.number,
    required this.lesson,
    required this.state,
    required this.unit,
  });

  final int number;
  final Lesson lesson;
  final LessonState state;
  final String unit;

  bool get _completed =>
      state.videoDone &&
      state.status == LessonStatus.loaded &&
      (!state.hasAssignment || state.isSubmitted);

  String get _statusText {
    if (!state.videoDone) {
      return 'Watch the full video to complete this $unit';
    }
    if (state.status != LessonStatus.loaded) return 'Video completed';
    if (!state.hasAssignment) return 'Completed';
    if (state.isSubmitted) {
      return 'Completed · Score ${state.result!.score}/${state.result!.total}';
    }
    return 'Video completed · Assignment pending';
  }

  @override
  Widget build(BuildContext context) {
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
            '$kClassSingular $number',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppPalette.primaryBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            lesson.title.isEmpty ? 'Untitled $unit' : lesson.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppPalette.authTextPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _completed
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_outline_rounded,
                size: 18,
                color: _completed
                    ? AppPalette.successColor
                    : AppPalette.primaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _completed
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
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppPalette.authTextPrimaryColor,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppPalette.authTextSecondaryColor,
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── materials ─────────────────────────

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
        borderRadius: BorderRadius.circular(18),
        boxShadow: classCardShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppPalette.primaryBlue.withValues(alpha: 0.12),
                  ),
                  child: Icon(_icon, color: AppPalette.primaryBlue, size: 24),
                ),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.authTextPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_label · Tap to open / download',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppPalette.authTextSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.download_rounded,
                  color: AppPalette.primaryBlue,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── assignment ─────────────────────────

class _AssignmentSection extends StatelessWidget {
  const _AssignmentSection({
    required this.state,
    required this.onSelect,
    required this.onSubmit,
  });

  final LessonState state;
  final void Function(String questionId, int optionIndex) onSelect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final unit = kClassSingular.toLowerCase();

    // No assignment for this class
    if (!state.hasAssignment) {
      if (!state.videoDone) return const SizedBox.shrink();
      return _InfoCard(
        icon: Icons.check_circle_outline_rounded,
        title: '$kClassSingular completed',
        subtitle: 'There is no assignment for this $unit.',
        isSuccess: true,
      );
    }

    // Locked until the video ends
    if (!state.videoDone) {
      return const _InfoCard(
        icon: Icons.lock_outline_rounded,
        title: 'Assignment locked',
        subtitle: 'Watch the full video to unlock the assignment.',
      );
    }

    final reviewing = state.isSubmitted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Assignment',
          trailing:
              '${state.totalMarks} ${state.totalMarks == 1 ? 'mark' : 'marks'}',
        ),
        const SizedBox(height: 12),
        if (reviewing) ...[
          _ResultCard(result: state.result!),
          const SizedBox(height: 16),
        ],
        for (int i = 0; i < state.questions.length; i++)
          _QuestionCard(
            number: i + 1,
            question: state.questions[i],
            selected: state.answers[state.questions[i].id],
            reviewing: reviewing,
            onSelect: (index) => onSelect(state.questions[i].id, index),
          ),
        if (!reviewing) ...[
          const SizedBox(height: 4),
          _PrimaryButton(
            label: state.allAnswered
                ? 'Submit assignment'
                : 'Answer all questions (${state.answeredCount}/${state.questions.length})',
            enabled: state.allAnswered && !state.submitting,
            loading: state.submitting,
            onTap: onSubmit,
          ),
          const SizedBox(height: 32), // space below the submit button
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final AssignmentResult result;

  @override
  Widget build(BuildContext context) {
    final good = result.percent >= 50;
    final color = good ? AppPalette.successColor : AppPalette.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, size: 38, color: color),
          const SizedBox(height: 6),
          const Text(
            'Your score',
            style: TextStyle(
              fontSize: 14,
              color: AppPalette.authTextSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${result.score} / ${result.total}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            '${result.percent}%',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

enum _OptionMode { idle, picked, correct, wrong }

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selected,
    required this.reviewing,
    required this.onSelect,
  });

  final int number;
  final AssignmentQuestion question;
  final int? selected;
  final bool reviewing;
  final ValueChanged<int> onSelect;

  _OptionMode _modeOf(int index) {
    if (reviewing) {
      if (index == question.correctIndex) return _OptionMode.correct;
      if (index == selected) return _OptionMode.wrong;
      return _OptionMode.idle;
    }
    return index == selected ? _OptionMode.picked : _OptionMode.idle;
  }

  @override
  Widget build(BuildContext context) {
    final gotIt = reviewing && selected == question.correctIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: classCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question $number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.primaryBlue,
                  ),
                ),
              ),
              Text(
                '${question.marks} ${question.marks == 1 ? 'mark' : 'marks'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.authTextSecondaryColor,
                ),
              ),
              if (reviewing) ...[
                const SizedBox(width: 8),
                Icon(
                  gotIt ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 20,
                  color: gotIt ? AppPalette.successColor : AppPalette.errorText,
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: AppPalette.authTextPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < question.options.length; i++)
            _OptionTile(
              letter: String.fromCharCode(65 + i),
              text: question.options[i],
              mode: _modeOf(i),
              onTap: reviewing ? null : () => onSelect(i),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.mode,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptionMode mode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent;
    switch (mode) {
      case _OptionMode.picked:
        accent = AppPalette.primaryBlue;
      case _OptionMode.correct:
        accent = AppPalette.successColor;
      case _OptionMode.wrong:
        accent = AppPalette.errorText;
      case _OptionMode.idle:
        accent = AppPalette.inputBorderColor;
    }

    final tinted = mode != _OptionMode.idle;

    IconData? trailing;
    switch (mode) {
      case _OptionMode.picked:
        trailing = Icons.radio_button_checked_rounded;
      case _OptionMode.correct:
        trailing = Icons.check_circle_rounded;
      case _OptionMode.wrong:
        trailing = Icons.cancel_rounded;
      case _OptionMode.idle:
        trailing = null;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: tinted ? accent.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tinted ? accent : Colors.transparent,
                    border: Border.all(color: accent, width: 1.5),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: tinted
                          ? AppPalette.white
                          : AppPalette.authTextSecondaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppPalette.authTextPrimaryColor,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailing, size: 22, color: accent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppPalette.primaryBlue
          : AppPalette.inputBorderColor.withValues(alpha: 0.6),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppPalette.white,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: enabled
                          ? AppPalette.white
                          : AppPalette.authTextSecondaryColor,
                    ),
                  ),
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
    this.isSuccess = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isError;
  final bool isSuccess;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSuccess
        ? AppPalette.successColor
        : AppPalette.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: classCardShadow(),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
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