import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/features/categories/providers/category_provider.dart';
import 'package:e_commerc_mobile_app/features/categories/screens/categories_screen.dart';
import 'package:e_commerc_mobile_app/features/categories/screens/category_products_screen.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';

void main() {
  testWidgets(
    'Tapping Electronics category navigates to CategoryProductsScreen with electronics products',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
          ],
          child: const MaterialApp(home: Scaffold(body: CategoriesScreen())),
        ),
      );

      await tester.pumpAndSettle();

      // Find Electronics category card
      final electronicsFinder = find.text('Electronics');
      expect(electronicsFinder, findsOneWidget);

      // Tap on Electronics category
      await tester.tap(electronicsFinder);
      await tester.pump(); // Immediate transition with NoAnimationPageRoute

      // Verify that CategoryProductsScreen is pushed immediately
      expect(find.byType(CategoryProductsScreen), findsOneWidget);

      // Verify search hint matches category
      expect(find.text('Search in Electronics...'), findsOneWidget);

      // Verify back button is present and pops back
      final backButtonFinder = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButtonFinder, findsOneWidget);

      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle();

      // Verify back on CategoriesScreen
      expect(find.byType(CategoryProductsScreen), findsNothing);
      expect(find.byType(CategoriesScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping Browse All Items navigates to CategoryProductsScreen for All Items without moving items',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
          ],
          child: const MaterialApp(home: Scaffold(body: CategoriesScreen())),
        ),
      );

      await tester.pumpAndSettle();

      // Find Browse All Items banner
      final allItemsFinder = find.text('Browse All Items');
      expect(allItemsFinder, findsOneWidget);

      // Tap on Browse All Items
      await tester.tap(allItemsFinder);
      await tester.pump(); // No duration needed for NoAnimationPageRoute

      // Verify CategoryProductsScreen is pushed immediately
      expect(find.byType(CategoryProductsScreen), findsOneWidget);
      expect(find.text('All Items'), findsOneWidget);
    },
  );
}
