import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerc_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerc_mobile_app/features/auth/providers/auth_provider.dart';
import 'package:e_commerc_mobile_app/features/auth/screens/login_screen.dart';
import 'package:e_commerc_mobile_app/features/auth/screens/sign_up_screen.dart';
import 'package:e_commerc_mobile_app/shared/widgets/custom_text_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Login & SignUp Theme Mode & Responsiveness Tests', () {
    testWidgets('LoginScreen renders cleanly in Dark Mode with dark theme surfaces', (
      WidgetTester tester,
    ) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify custom text fields are present
      expect(find.byType(CustomTextField), findsNWidgets(2));

      // Verify Dark scaffold background is active
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0B0F19));

      // Verify Login button exists
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('SignUpScreen renders cleanly in Dark Mode with dark theme surfaces', (
      WidgetTester tester,
    ) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SignUpScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify custom text fields are present
      expect(find.byType(CustomTextField), findsNWidgets(4));

      // Verify Dark scaffold background is active
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0B0F19));

      // Verify Create Account button exists
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('LoginScreen does not overflow on small screen when virtual keyboard opens', (
      WidgetTester tester,
    ) async {
      // Simulate compact screen size (e.g. iPhone SE / small Android: 360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate keyboard opening with 250px bottom inset
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(() {
        tester.view.resetViewInsets();
      });

      await tester.pumpAndSettle();

      // Scroll and verify no overflow exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('Empty submission triggers validation errors on fields', (
      WidgetTester tester,
    ) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Login button with empty inputs
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Validation errors should be visible according to Validators definitions
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });
}
