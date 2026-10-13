import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerc_mobile_app/features/auth/providers/auth_provider.dart';
import 'package:e_commerc_mobile_app/features/auth/screens/login_screen.dart';
import 'package:e_commerc_mobile_app/features/auth/screens/sign_up_screen.dart';
import 'package:e_commerc_mobile_app/features/auth/widgets/social_login_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Minimalist LoginScreen Tests', () {
    testWidgets('Renders all redesigned header, fields, buttons, and social options', (
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

      // Header title and subtitle
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('New user? '), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);

      // Email and password fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);

      // Main action button
      expect(find.text('Login'), findsOneWidget);

      // Social login section
      expect(find.byType(SocialLoginSection), findsOneWidget);
      expect(find.text('or'), findsOneWidget);
      expect(
        find.text('Join With Your Favourite Social Media Account'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.facebook), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);

      // Legal notice
      expect(find.textContaining("Terms of Service"), findsOneWidget);
      expect(find.textContaining("Privacy Policy"), findsOneWidget);
    });

    testWidgets('Tapping password eye icon toggles obscurity', (
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

      final toggleFinder = find.byIcon(Icons.visibility_outlined);
      expect(toggleFinder, findsOneWidget);

      await tester.tap(toggleFinder);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('Tapping Create an account switches to SignUpScreen', (
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

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('Valid login submission calls AuthProvider.login', (
      WidgetTester tester,
    ) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            routes: {
              '/main-nav': (_) => const Scaffold(body: Text('Main Navigation')),
            },
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter credentials manually
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'student@example.com');
      await tester.enterText(fields.at(1), 'password123');

      await tester.tap(find.text('Login'));
      await tester.pump(); // Start loading
      await tester.pump(const Duration(milliseconds: 1300)); // Complete latency

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, 'student@example.com');
    });
  });

  group('Minimalist SignUpScreen Tests', () {
    testWidgets('Renders all redesigned registration fields, buttons, and social options', (
      WidgetTester tester,
    ) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Header title and subtitle
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);

      // 4 input fields: Name, Email, Password, Confirm Password
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);

      // Main action button
      expect(find.text('Create Account'), findsOneWidget);

      // Social login section
      expect(find.byType(SocialLoginSection), findsOneWidget);
    });

    testWidgets('Tapping Sign in switches to LoginScreen', (
      WidgetTester tester,
    ) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('Valid sign up submission creates user account in AuthProvider', (
      WidgetTester tester,
    ) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            routes: {
              '/main-nav': (_) => const Scaffold(body: Text('Main Navigation')),
            },
            home: const SignUpScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Alice Cooper');
      await tester.enterText(textFields.at(1), 'alice@example.com');
      await tester.enterText(textFields.at(2), 'securePass123');
      await tester.enterText(textFields.at(3), 'securePass123');

      final submitBtn = find.text('Create Account');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, 'alice@example.com');
      expect(authProvider.currentUser?.fullName, 'Alice Cooper');
    });
  });
}
