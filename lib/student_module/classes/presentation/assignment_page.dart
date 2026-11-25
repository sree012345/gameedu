import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';

import '../bloc/lesson_bloc.dart';
import 'widgets/gradient_header.dart';
import 'widgets/lesson_widgets.dart';

/// The assignment of a class, on its own page.
/// Open it with the SAME LessonBloc as the class page:
///
///   BlocProvider<LessonBloc>.value(value: bloc, child: const AssignmentPage())
class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// After a successful submit: go up to the score card.
  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return BlocListener<LessonBloc, LessonState>(
      listenWhen: (p, c) => !p.isSubmitted && c.isSubmitted,
      listener: (context, state) => _scrollToTop(),
      child: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          final bloc = context.read<LessonBloc>();
          final reviewing = state.isSubmitted;

          return Scaffold(
            backgroundColor: AppPalette.infoSurfaceColor,
            body: Column(
              children: [
                GradientHeader(
                  title: 'Assignment',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!state.hasAssignment)
                          const LessonInfoCard(
                            icon: Icons.assignment_outlined,
                            title: 'No assignment',
                            subtitle: 'There is no assignment for this class.',
                          )
                        else if (!state.videoDone)
                          const LessonInfoCard(
                            icon: Icons.lock_outline_rounded,
                            title: 'Assignment locked',
                            subtitle:
                                'Watch all the lesson videos to unlock the assignment.',
                          )
                        else ...[
                          LessonSectionTitle(
                            title: 'Class Assignment',
                            trailing:
                                '${state.totalMarks} ${state.totalMarks == 1 ? 'mark' : 'marks'}',
                          ),
                          const SizedBox(height: 12),
                          if (reviewing) ...[
                            LessonResultCard(result: state.result!),
                            const SizedBox(height: 16),
                          ],
                          for (int i = 0; i < state.questions.length; i++)
                            LessonQuestionCard(
                              number: i + 1,
                              question: state.questions[i],
                              selected: state.answers[state.questions[i].id],
                              reviewing: reviewing,
                              onSelect: (index) => bloc.add(
                                AnswerSelected(state.questions[i].id, index),
                              ),
                            ),
                          if (!reviewing) ...[
                            const SizedBox(height: 4),
                            LessonPrimaryButton(
                              label: state.allAnswered
                                  ? 'Submit assignment'
                                  : 'Answer all questions (${state.answeredCount}/${state.questions.length})',
                              enabled: state.allAnswered && !state.submitting,
                              loading: state.submitting,
                              onTap: () => _confirmSubmit(bloc, state),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}