import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Class times are shown in IST.
DateTime toIst(DateTime dt) =>
    dt.toUtc().add(const Duration(hours: 5, minutes: 30));

/// "23 Nov 2026"
String formatDate(DateTime dt) {
  final d = toIst(dt);
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// "11:00 AM"
String formatTime(DateTime dt) {
  final d = toIst(dt);
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}

/// "11:00 AM - 12:00 PM"
String formatRange(DateTime start, DateTime end) =>
    '${formatTime(start)} - ${formatTime(end)}';

/// 1h, 1h 45m, 45m
String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

/// Icon + gradient for a class `thumbnailKey`. Add your keys to [_icons].
class ClassThumb {
  const ClassThumb(this.icon, this.colors);

  final IconData icon;
  final List<Color> colors;
}

class ClassThumbnails {
  ClassThumbnails._();

  static const Map<String, IconData> _icons = {
    'track_design': Icons.route_outlined,
    'game_design': Icons.sports_esports_outlined,
    'unity': Icons.view_in_ar_outlined,
    'unreal_engine': Icons.videocam_outlined,
    'esports': Icons.emoji_events_outlined,
    'level_design': Icons.location_on_outlined,
    'game_audio': Icons.music_note_outlined,
    'pixel_art': Icons.image_outlined,
    'modeling_3d': Icons.view_in_ar_outlined,
    'csharp': Icons.code_rounded,
  };

  static const List<List<Color>> _gradients = [
    [AppPalette.primaryBlueLight, AppPalette.primaryBlueDark],
    [AppPalette.accentCyan, AppPalette.primaryBlue],
    [AppPalette.successColor, AppPalette.accentCyan],
    [AppPalette.accentGold, AppPalette.errorText],
  ];

  static ClassThumb of(String key) {
    // Stable index from the key (same key -> same colours)
    final index = key.codeUnits.fold<int>(0, (a, b) => a + b) % _gradients.length;
    return ClassThumb(
      _icons[key] ?? Icons.menu_book_outlined,
      _gradients[index],
    );
  }
}
