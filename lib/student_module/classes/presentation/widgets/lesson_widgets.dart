import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/student_module/classes/models/lesson_model.dart';

import 'class_card.dart';

/// Shared small widgets of the class page and the assignment page.
/// Put this file in: presentation/widgets/lesson_widgets.dart

class LessonSectionTitle extends StatelessWidget {
  const LessonSectionTitle({super.key, required this.title, this.trailing});

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
              fontSize: 22,
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

class LessonInfoCard extends StatelessWidget {
  const LessonInfoCard({
    super.key,
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

class LessonPrimaryButton extends StatelessWidget {
  const LessonPrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.loading = false,
    this.trailingIcon,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final textColor = enabled
        ? AppPalette.white
        : AppPalette.authTextSecondaryColor;

    return Material(
      color: enabled
          ? AppPalette.primaryBlue
          : AppPalette.inputBorderColor.withValues(alpha: 0.6),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: enabled && !loading ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
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
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(trailingIcon, size: 20, color: textColor),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class LessonResultCard extends StatelessWidget {
  const LessonResultCard({super.key, required this.result});

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

class LessonQuestionCard extends StatelessWidget {
  const LessonQuestionCard({
    super.key,
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