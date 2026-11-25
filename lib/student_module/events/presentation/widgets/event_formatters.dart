import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

const List<String> _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Event dates are shown in IST.
DateTime toIst(DateTime dt) =>
    dt.toUtc().add(const Duration(hours: 5, minutes: 30));

/// "16 January 2027"
String formatLongDate(DateTime dt) {
  final d = toIst(dt);
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// Icon + colours of the picture tile (used when an event has no image).
class EventTile {
  const EventTile(this.icon, this.colors);

  final IconData icon;
  final List<Color> colors;
}

class EventTiles {
  EventTiles._();

  static const Map<String, IconData> _icons = {
    'racing': Icons.sports_motorsports_outlined,
    'game_dev': Icons.laptop_chromebook_outlined,
    'hackathon': Icons.code_rounded,
    'esports': Icons.emoji_events_outlined,
    'art': Icons.brush_outlined,
    'workshop': Icons.build_outlined,
  };

  static const List<List<Color>> _gradients = [
    [AppPalette.primaryBlueLight, AppPalette.primaryBlueDark],
    [AppPalette.accentCyan, AppPalette.primaryBlue],
    [AppPalette.successColor, AppPalette.accentCyan],
    [AppPalette.accentGold, AppPalette.errorText],
  ];

  static EventTile of(String category) {
    final index =
        category.codeUnits.fold<int>(0, (a, b) => a + b) % _gradients.length;
    return EventTile(_icons[category] ?? Icons.event_outlined, _gradients[index]);
  }
}
