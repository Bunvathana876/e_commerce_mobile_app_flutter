import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerc_mobile_app/app/app.dart';
import 'package:e_commerc_mobile_app/features/auth/models/user_model.dart';
import 'package:e_commerc_mobile_app/features/auth/providers/auth_provider.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/categories/providers/category_provider.dart';
import 'package:e_commerc_mobile_app/features/navigation/main_navigation_screen.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/features/profile/settings/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Persistence Tests', () {
    test('login persists token and user data to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final authProvider = AuthProvider();

      final success = await authProvider.login(
        'student@example.com',
        'password123',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.fullName, 'Bun Vathana');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNotNull);
      expect(prefs.getString('auth_user'), contains('student@example.com'));
    });

    test(
      'AuthProvider restores user session when initialized with saved prefs',
      () async {
        const mockUser = UserModel(
          id: 1,
          email: 'saved_user@example.com',
          fullName: 'Saved User',
          role: 'customer',
        );

        SharedPreferences.setMockInitialValues({
          'auth_token': 'saved_jwt_token',
          'auth_user': jsonEncode(mockUser.toJson()),
        });

        final prefs = await SharedPreferences.getInstance();
        final authProvider = AuthProvider(initialPrefs: prefs);

        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.token, 'saved_jwt_token');
        expect(authProvider.currentUser?.email, 'saved_user@example.com');
        expect(authProvider.currentUser?.fullName, 'Saved User');
      },
    );

    test(
      'logout clears persistent token and user data from SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({
          'auth_token': 'token_to_remove',
          'auth_user': jsonEncode({
            'id': 2,
            'email': 'remove_me@example.com',
            'full_name': 'Remove Me',
            'role': 'customer',
          }),
        });

        final prefs = await SharedPreferences.getInstance();
        final authProvider = AuthProvider(initialPrefs: prefs);
        expect(authProvider.isAuthenticated, isTrue);

        await authProvider.logout();

        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.currentUser, isNull);
        expect(authProvider.token, isNull);

        final updatedPrefs = await SharedPreferences.getInstance();
        expect(updatedPrefs.getString('auth_token'), isNull);
        expect(updatedPrefs.getString('auth_user'), isNull);
      },
    );

    testWidgets(
      'App opens directly to MainNavigationScreen when user is already logged in',
      (WidgetTester tester) async {
        const savedUser = UserModel(
          id: 1,
          email: 'student@example.com',
          fullName: 'Bun Vathana',
          role: 'customer',
        );

        SharedPreferences.setMockInitialValues({
          'auth_token': 'valid_token',
          'auth_user': jsonEncode(savedUser.toJson()),
        });

        final prefs = await SharedPreferences.getInstance();
        final authProvider = AuthProvider(initialPrefs: prefs);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: authProvider),
              ChangeNotifierProvider(create: (_) => ProductProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => CategoryProvider()),
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ],
            child: const MyApp(),
          ),
        );

        // Verify MainNavigationScreen renders instead of Welcome Screen
        expect(find.byType(MainNavigationScreen), findsOneWidget);
        expect(find.text('Categories'), findsWidgets);
      },
    );
  });
}
