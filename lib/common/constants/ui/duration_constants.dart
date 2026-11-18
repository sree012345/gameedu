/*
/// ---------------------------------------------------------------------------
/// [DurationConstants]
/// ---------------------------------------------------------------------------
/// Centralizes all durations used across the app such as:
/// - Animation timings
/// - UI transitions
/// - Feedback delays
/// - Toast/snackbar visibility
///
/// ✅ Benefits:
/// - Consistent experience across screens
/// - Easier to tweak and optimize animations globally
/// ---------------------------------------------------------------------------
*/
class DurationConstants {
  // ⏱️ General durations

  static const Duration tiny = Duration(milliseconds: 100);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration long = Duration(milliseconds: 800);

  // ⏱️ scroll durations
  static const Duration scrollDuration = Duration(milliseconds: 300);

  // 🎬 Animation durations
  static const Duration fadeIn = Duration(milliseconds: 300);
  static const Duration fadeOut = Duration(milliseconds: 250);
  static const Duration slide = Duration(milliseconds: 350);
}
