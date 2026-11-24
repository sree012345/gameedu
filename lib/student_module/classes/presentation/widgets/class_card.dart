import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

import '../../models/class_item.dart';
import 'class_formatters.dart';

List<BoxShadow> classCardShadow() => [
  BoxShadow(
    color: AppPalette.buttonShadowColor.withValues(alpha: 0.7),
    blurRadius: 14,
    offset: const Offset(0, 5),
  ),
];

/// Coloured square with the class icon.
class ClassThumbTile extends StatelessWidget {
  const ClassThumbTile({super.key, required this.thumbnailKey, this.size = 92});

  final String thumbnailKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    final thumb = ClassThumbnails.of(thumbnailKey);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: thumb.colors,
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Icon(thumb.icon, color: AppPalette.white, size: size * 0.46),
    );
  }
}

/// One class in the list.
class ClassCard extends StatelessWidget {
  const ClassCard({super.key, required this.item, required this.onView});

  final ClassItem item;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final live = item.statusAt(DateTime.now()) == ClassStatus.live;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: classCardShadow(),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClassThumbTile(thumbnailKey: item.thumbnailKey),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.authTextPrimaryColor,
                            ),
                          ),
                        ),
                        if (live) ...[
                          const SizedBox(width: 8),
                          const _LiveChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    _MetaRow(
                      icon: Icons.person_outline_rounded,
                      text: item.mentorName.isEmpty
                          ? 'Mentor to be announced'
                          : item.mentorName,
                    ),
                    _MetaRow(
                      icon: Icons.calendar_today_outlined,
                      text: formatDate(item.startsAt),
                    ),
                    _MetaRow(
                      icon: Icons.schedule_rounded,
                      text:
                          '${formatRange(item.startsAt, item.endsAt)} · ${formatDuration(item.duration)}',
                    ),
                    if (!item.isGeneral && item.college != null)
                      _MetaRow(
                        icon: Icons.school_outlined,
                        text: '${item.college} only',
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _TopicChip(label: item.topicLabel)),
              const SizedBox(width: 10),
              _ViewButton(onTap: onView),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppPalette.primaryBlue),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppPalette.authTextSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppPalette.primaryBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell_outlined, size: 16, color: AppPalette.primaryBlue),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppPalette.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.primaryBlue.withValues(alpha: 0.12),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          child: Text(
            'View Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppPalette.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppPalette.errorText,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppPalette.white,
        ),
      ),
    );
  }
}
