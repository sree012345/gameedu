/*
 * ---------------------------------------------------------------------------
 * File        : lib/common/constants/language_constants.dart
 * Description : Central place for language names, codes, search keywords,
 *               and region-to-language mapping.
 * Author      : Revolution Games Private Limited
 * Created On  : 2025-12-17
 * Last Updated: 2026-02-03
 * ---------------------------------------------------------------------------
 * © 2025-2026 Revolution Games Private Limited. All rights reserved.
 * ---------------------------------------------------------------------------
 */

class LanguageConstants {
  /// Supported language display names
  static const String english = "English";
  static const String hindi = "हिन्दी";
  static const String tamil = "தமிழ்";
  static const String malayalam = "മലയാളം";
  static const String kannada = "ಕನ್ನಡ";
  static const String telugu = "తెలుగు";
  static const String gujarati = "ગુજરાતી";
  static const String marathi = "मराठी";
  static const String bengali = "বাংলা";
  static const String punjabi = "ਪੰਜਾਬੀ";

  /// Language Codes
  static const String codeEnglish = "en";
  static const String codeHindi = "hi";
  static const String codeTamil = "ta";
  static const String codeMalayalam = "ml";
  static const String codeKannada = "kn";
  static const String codeTelugu = "te";
  static const String codeGujarati = "gu";
  static const String codeMarathi = "mr";
  static const String codeBengali = "bn";
  static const String codePunjabi = "pa";

  /// All languages (UI list)
  static const List<String> allLanguages = [
    english,
    tamil,
    malayalam,
    hindi,
    telugu,
    kannada,
    gujarati,
    marathi,
    bengali,
    punjabi,
  ];

  /// Default fallback languages (UI list)
  static const List<String> defaultLanguages = [english, hindi];

  /// State → Suggested Languages (UI list)
  static final Map<String, List<String>> stateLanguageMap = {
    "tamil": [english, tamil], // Tamil Nadu
    "kerala": [english, malayalam], // Kerala
    "karnataka": [english, kannada], // Karnataka
    "andhra": [english, telugu], // Andhra Pradesh
    "telangana": [english, telugu], // Telangana
    "gujarat": [english, gujarati], // Gujarat
    "maharashtra": [english, marathi], // Maharashtra
    "west bengal": [english, bengali], // West Bengal
    "punjab": [english, punjabi], // Punjab
  };

  /// Language → Keywords for search
  static final List<(String native, String keyword)> languageKeywords = [
    (english, "english"),

    (hindi, "hindi"),
    (hindi, "हिन्दी"),

    (tamil, "tamil"),
    (tamil, "தமிழ்"),

    (malayalam, "malayalam"),
    (malayalam, "മലയാളം"),

    (kannada, "kannada"),
    (kannada, "ಕನ್ನಡ"),

    (telugu, "telugu"),
    (telugu, "తెలుగు"),

    (gujarati, "gujarati"),
    (gujarati, "ગુજરાતી"),

    (marathi, "marathi"),
    (marathi, "मराठी"),

    (bengali, "bengali"),
    (bengali, "বাংলা"),

    (punjabi, "punjabi"),
    (punjabi, "ਪੰਜਾਬੀ"),
  ];

  /// Convert Display Name → Language Code
  static String getCodeFromName(String languageName) {
    final lower = languageName.toLowerCase();

    switch (lower) {
      case "english":
      case english:
        return codeEnglish;

      case "hindi":
      case "हिन्दी":
        return codeHindi;

      case "tamil":
      case "தமிழ்":
        return codeTamil;

      case "malayalam":
      case "മലയാളം":
        return codeMalayalam;

      case "kannada":
      case "ಕನ್ನಡ":
        return codeKannada;

      case "telugu":
      case "తెలుగు":
        return codeTelugu;

      case "gujarati":
      case "ગુજરાતી":
        return codeGujarati;

      case "marathi":
      case "मराठी":
        return codeMarathi;

      case "bengali":
      case "বাংলা":
        return codeBengali;

      case "punjabi":
      case "ਪੰਜਾਬੀ":
        return codePunjabi;

      default:
        return codeEnglish;
    }
  }

  /// Convert Code → Display Name
  static String getNameFromCode(String code) {
    switch (code) {
      case codeEnglish:
        return english;
      case codeHindi:
        return hindi;
      case codeTamil:
        return tamil;
      case codeMalayalam:
        return malayalam;
      case codeKannada:
        return kannada;
      case codeTelugu:
        return telugu;
      case codeGujarati:
        return gujarati;
      case codeMarathi:
        return marathi;
      case codeBengali:
        return bengali;
      case codePunjabi:
        return punjabi;
      default:
        return english;
    }
  }
}
