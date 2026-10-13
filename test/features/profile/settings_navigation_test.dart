import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/features/auth/providers/auth_provider.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/features/categories/providers/category_provider.dart';
import 'package:e_commerc_mobile_app/features/profile/screens/profile_screen.dart';
import 'package:e_commerc_mobile_app/features/profile/settings/providers/theme_provider.dart';
import 'package:e_commerc_mobile_app/features/profile/settings/screens/settings_screen.dart';

void main() {
  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    );
  }

  testWidgets(
    'Tapping AppBar Settings button navigates to SettingsScreen and back',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find AppBar settings icon button
      final settingsButtonFinder = find.byTooltip('Settings');
      expect(settingsButtonFinder, findsOneWidget);

      // Tap settings button
      await tester.tap(settingsButtonFinder);
      await tester.pumpAndSettle();

      // Verify SettingsScreen is displayed
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('Dark Theme'), findsOneWidget);

      // Tap back button
      final backButtonFinder = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButtonFinder, findsOneWidget);

      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle();

      // Verify back on ProfileScreen
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    },
  );

  testWidgets('Tapping App Settings tile in list navigates to SettingsScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Scroll to and find App Settings tile
    final settingsTileFinder = find.text('App Settings');
    await tester.scrollUntilVisible(settingsTileFinder, 200);
    expect(settingsTileFinder, findsOneWidget);

    // Tap App Settings tile
    await tester.tap(settingsTileFinder);
    await tester.pumpAndSettle();

    // Verify SettingsScreen is displayed
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Dark Theme'), findsOneWidget);
  });

  testWidgets('Toggling Dark Theme switch updates ThemeProvider state', (
    WidgetTester tester,
  ) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: themeProvider)],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(themeProvider.isDarkMode, isFalse);

    final darkThemeTile = find.widgetWithText(ListTile, 'Dark Theme');
    expect(darkThemeTile, findsOneWidget);

    final switchFinder = find.descendant(
      of: darkThemeTile,
      matching: find.byType(Switch),
    );
    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(themeProvider.isDarkMode, isTrue);
    expect(find.text('Dark mode enabled'), findsOneWidget);
  });
}
