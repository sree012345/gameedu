import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LanguageCubit extends Cubit<Locale> {
  // This is the exact key EasyLocalization uses internally
  static const String _easyLocaleKey = 'locale';

  LanguageCubit() : super(const Locale('en')) {
    _restoreLocale();
  }

  Future<void> _restoreLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_easyLocaleKey);
      debugPrint("🌐 [LanguageCubit] Restored locale: $saved");
      if (saved != null && saved.isNotEmpty) {
        emit(Locale(saved));
      }
    } catch (e) {
      debugPrint("🌐 [LanguageCubit] Failed to restore locale: $e");
    }
  }

  Future<void> changeLanguage(Locale locale, BuildContext context) async {
    debugPrint("🌐 [LanguageCubit] Changing to: ${locale.languageCode}");
    await context.setLocale(locale); // EasyLocalization persists this
    emit(locale);
  }
}