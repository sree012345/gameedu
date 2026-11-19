/// Asset paths used by the auth screens.
/// Drop the images in `assets/images/auth/` and declare that folder in
/// pubspec.yaml. Until then, simple fallback visuals are shown.
class AuthAssets {
  AuthAssets._();

  static const String _base = 'assets/images/auth';

  static const String logo = '$_base/game_edu_logo.png';
  static const String loginHero = '$_base/login_hero.png';
  static const String otpHero = '$_base/otp_envelope.png';
}
