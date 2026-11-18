import 'package:flutter/widgets.dart';

/// ---------------------------------------------------------------------------
/// [LocalizationManager]
/// ---------------------------------------------------------------------------
/// - Handles tracking loaded modules (for analytics, memory reporting).
/// - Actual merging is handled by MergedAssetLoader.
/// ---------------------------------------------------------------------------
class LocalizationManager {
  static final Set<String> _loadedModules = {};

  /// Call this to mark a module as loaded
  static Future<void> loadModule(String moduleName) async {
    if (_loadedModules.contains(moduleName)) return;
    _loadedModules.add(moduleName);
    debugPrint('✅ Localization module loaded: $moduleName');
  }

  /// Optionally clear tracking when modules are not in use
  static void clearLoadedModules() {
    _loadedModules.clear();
    debugPrint('🧹 Localization modules cleared');
  }

  /// Optional: Unload module manually if needed
  static void unloadModule(String moduleName) {
    _loadedModules.remove(moduleName);
    // Cannot remove JSON from translations map as of now (EasyLocalization limitation)
    // But can reset to fallbackLocale or reload app if memory is critical
  }

  /// View what’s loaded
  static List<String> get loadedModules => _loadedModules.toList();
}
