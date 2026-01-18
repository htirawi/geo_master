import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/di/service_locator.dart';
import '../../core/theme/app_theme.dart';

/// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;

  void _loadThemeMode() {
    final savedMode = _prefs.getString(_keyThemeMode);
    if (savedMode != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode.name);
    state = mode;
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Check if dark mode
  bool get isDarkMode => state == ThemeMode.dark;
}

/// Theme mode provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = sl<SharedPreferences>();
  return ThemeModeNotifier(prefs);
});

/// Light theme provider
final lightThemeProvider = Provider.family<ThemeData, bool>((ref, isArabic) {
  final appTheme = AppTheme(isArabic: isArabic);
  return appTheme.lightTheme;
});

/// Dark theme provider
final darkThemeProvider = Provider.family<ThemeData, bool>((ref, isArabic) {
  final appTheme = AppTheme(isArabic: isArabic);
  return appTheme.darkTheme;
});

/// Is dark mode provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  // Note: This doesn't account for system theme
  // In actual usage, use Theme.of(context).brightness
  return themeMode == ThemeMode.dark;
});
