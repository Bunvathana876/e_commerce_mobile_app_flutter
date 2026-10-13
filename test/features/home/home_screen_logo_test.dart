import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/categories/providers/category_provider.dart';
import 'package:e_commerc_mobile_app/features/home/screens/home_screen.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/shared/widgets/app_logo.dart';

void main() {
  testWidgets('HomeScreen displays Blue Panda logo and header elements', (
    WidgetTester tester,
  ) async {
    final productProvider = ProductProvider();
    final categoryProvider = CategoryProvider();
    final cartProvider = CartProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: productProvider),
          ChangeNotifierProvider.value(value: categoryProvider),
          ChangeNotifierProvider.value(value: cartProvider),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify logo and brand header elements are present
    expect(find.byType(AppLogo), findsOneWidget);

    final appLogo = tester.widget<AppLogo>(find.byType(AppLogo));
    expect(appLogo.imagePath, equals('assets/images/logo_panda_blue.png'));

    expect(find.text('Blue Panda'), findsOneWidget);
    expect(find.text('Explore trending gear'), findsOneWidget);
    expect(find.text('Search products, brands, gear...'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // Verify See all is displayed and Swipe for more is removed
    expect(find.text('See all'), findsOneWidget);
    expect(find.text('Swipe for more'), findsNothing);
  });

  testWidgets(
    'Tapping See all triggers onSeeAllCategories callback when supplied',
    (WidgetTester tester) async {
      var callbackTriggered = false;
      final productProvider = ProductProvider();
      final categoryProvider = CategoryProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: productProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: cartProvider),
          ],
          child: MaterialApp(
            home: HomeScreen(
              onSeeAllCategories: () {
                callbackTriggered = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();

      expect(callbackTriggered, isTrue);
    },
  );

  testWidgets(
    'Tapping See all navigates to CategoriesScreen when no callback is supplied',
    (WidgetTester tester) async {
      final productProvider = ProductProvider();
      final categoryProvider = CategoryProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: productProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: cartProvider),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();

      // Verify that CategoriesScreen is pushed
      expect(find.text('Search collections & departments...'), findsOneWidget);
    },
  );
}

