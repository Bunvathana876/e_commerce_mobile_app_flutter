import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerc_mobile_app/features/profile/settings/providers/theme_provider.dart';

void main() {
  group('ThemeProvider Persistence Tests', () {
    test('loads saved dark mode preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();

      final provider = ThemeProvider(initialPrefs: prefs);
      expect(provider.isDarkMode, isTrue);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('loads saved light mode preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});
      final prefs = await SharedPreferences.getInstance();

      final provider = ThemeProvider(initialPrefs: prefs);
      expect(provider.isDarkMode, isFalse);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme persists new preference to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final provider = ThemeProvider(initialPrefs: prefs);
      expect(provider.isDarkMode, isFalse);

      provider.toggleTheme(true);
      await Future<void>.delayed(Duration.zero);
      expect(provider.isDarkMode, isTrue);

      final updatedPrefs = await SharedPreferences.getInstance();
      expect(updatedPrefs.getString('app_theme_mode'), 'dark');

      provider.toggleTheme(false);
      await Future<void>.delayed(Duration.zero);
      expect(provider.isDarkMode, isFalse);
      expect(updatedPrefs.getString('app_theme_mode'), 'light');
    });
  });
}
