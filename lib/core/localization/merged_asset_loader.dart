import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class MergedAssetLoader extends AssetLoader {
  final List<String> localizationPaths;

  const MergedAssetLoader(this.localizationPaths);

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final localeCode = locale.languageCode;
    final Map<String, dynamic> result = {};

    for (final folder in localizationPaths) {
      final assetPath = '$folder/$localeCode.json';
      try {
        final data = await rootBundle.loadString(assetPath);
        final jsonMap = json.decode(data) as Map<String, dynamic>;
        result.addAll(jsonMap); // merges all keys
      } catch (_) {
        // Optional: print warning if file is missing
      }
    }

    return result;
  }
}
