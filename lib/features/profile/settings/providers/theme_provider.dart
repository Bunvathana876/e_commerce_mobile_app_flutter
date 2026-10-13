import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Manages light, dark, and system theme modes with SharedPreferences persistence.
class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  // Load saved theme synchronously if prefs are provided, otherwise asynchronously
  ThemeProvider({SharedPreferences? initialPrefs}) {
    if (initialPrefs != null) {
      _loadFromPrefs(initialPrefs);
    } else {
      _loadSavedTheme();
    }
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Reads theme mode from SharedPreferences
  void _loadFromPrefs(SharedPreferences prefs) {
    try {
      final savedMode = prefs.getString(_keyThemeMode);
      if (savedMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedMode == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedMode == 'system') {
        _themeMode = ThemeMode.system;
      }
    } catch (e) {
      debugPrint('Failed to load saved theme mode: $e');
    }
  }

  // Loads theme preference from persistent storage
  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _loadFromPrefs(prefs);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load theme from preferences: $e');
    }
  }

  // Saves theme preference to persistent storage
  Future<void> _saveThemeToPrefs(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, mode);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  // Switch between light and dark mode
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _saveThemeToPrefs(isDark ? 'dark' : 'light');
  }

  // Updates theme to a specific mode (light, dark, or system)
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveThemeToPrefs(mode.name);
  }
}
