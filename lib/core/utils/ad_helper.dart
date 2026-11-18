import 'dart:io';

class AdHelper {
  // 🔁 Change this to false before releasing
  static const bool _isTest = true;

  // ─── Banner ───────────────────────────
  static String get bannerAdUnitId {
    if (_isTest) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'  // Android test
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS test
    } else {
      return Platform.isAndroid
          ? 'YOUR_REAL_ANDROID_BANNER_ID'  // Replace before release
          : 'YOUR_REAL_IOS_BANNER_ID';     // Replace before release
    }
  }

  // ─── Interstitial ─────────────────────
  static String get interstitialAdUnitId {
    if (_isTest) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'  // Android test
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS test
    } else {
      return Platform.isAndroid
          ? 'YOUR_REAL_ANDROID_INTERSTITIAL_ID'
          : 'YOUR_REAL_IOS_INTERSTITIAL_ID';
    }
  }

  // ─── Rewarded ─────────────────────────
  static String get rewardedAdUnitId {
    if (_isTest) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'  // Android test
          : 'ca-app-pub-3940256099942544/1712485313'; // iOS test
    } else {
      return Platform.isAndroid
          ? 'YOUR_REAL_ANDROID_REWARDED_ID'
          : 'YOUR_REAL_IOS_REWARDED_ID';
    }
  }
}