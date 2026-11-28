import 'package:intl/intl.dart';

class CommunityFormatters {
  CommunityFormatters._();

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// List screen: `10:24`, `Yesterday`, or `24/11/26`.
  static String listTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    if (isSameDay(time, now)) return DateFormat('H:mm').format(time);
    if (isSameDay(time, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('dd/MM/yy').format(time);
  }

  static String bubbleTime(DateTime time) => DateFormat('H:mm').format(time);

  static String dayHeader(DateTime time) {
    final now = DateTime.now();
    if (isSameDay(time, now)) return 'Today';
    if (isSameDay(time, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('d MMM yyyy').format(time);
  }
}
