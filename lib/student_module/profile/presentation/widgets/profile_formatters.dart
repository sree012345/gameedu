/// 1 -> "1st Year", 2 -> "2nd Year", 3 -> "3rd Year", 4 -> "4th Year".
String yearLabel(int? year) {
  if (year == null) return '';
  return switch (year) {
    1 => '1st Year',
    2 => '2nd Year',
    3 => '3rd Year',
    _ => '${year}th Year',
  };
}

/// "+919876543210" -> "+91 98765 43210". Other values are returned as is.
String formatPhone(String phone) {
  final p = phone.trim();
  if (p.startsWith('+91') && p.length == 13) {
    return '+91 ${p.substring(3, 8)} ${p.substring(8)}';
  }
  return p;
}
