import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/categories/providers/category_provider.dart';
import 'package:e_commerc_mobile_app/features/home/screens/home_screen.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';

void main() {
  group('Below-the-fold Lazy Loading Tests', () {
    test(
      'ProductProvider initially loads only first page (6 items) below the fold',
      () {
        final provider = ProductProvider();

        expect(provider.filteredProducts.length, greaterThan(6));
        expect(provider.displayedProducts.length, equals(6));
        expect(provider.hasMore, isTrue);
        expect(provider.isLoadingMore, isFalse);
      },
    );

    test('loadMore lazily appends the next page of items', () async {
      final provider = ProductProvider();
      expect(provider.displayedProducts.length, equals(6));

      final future = provider.loadMore();
      expect(provider.isLoadingMore, isTrue);

      await future;

      expect(provider.isLoadingMore, isFalse);
      expect(provider.displayedProducts.length, equals(12));
    });

    test(
      'selectCategory and setSearchQuery reset pagination back to initial batch',
      () async {
        final provider = ProductProvider();
        await provider.loadMore();
        expect(provider.displayedProducts.length, equals(12));

        // Selecting category resets to initial batch
        provider.selectCategory(1);
        expect(provider.displayedProducts.length, lessThanOrEqualTo(6));

        // Reset to all
        provider.selectCategory(0);
        expect(provider.displayedProducts.length, equals(6));

        await provider.loadMore();
        expect(provider.displayedProducts.length, equals(12));

        // Searching resets to initial batch
        provider.setSearchQuery('laptop');
        expect(provider.displayedProducts.length, lessThanOrEqualTo(6));
      },
    );

    testWidgets(
      'HomeScreen renders initial batch and lazy-loads more items on scroll down',
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

        // Above the fold elements are rendered
        expect(find.text('Categories'), findsOneWidget);
        expect(find.text('Popular Items'), findsOneWidget);

        // Verify initial batch count is 6
        expect(productProvider.displayedProducts.length, equals(6));

        // Scroll down below the fold towards the bottom of the initial 6 products
        await tester.drag(find.text('Popular Items'), const Offset(0, -800));
        await tester.pump();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
        await tester.pump();

        // Advance past simulated loadMore delay
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pump();

        // Verify that more items were lazily loaded
        expect(productProvider.displayedProducts.length, greaterThan(6));
      },
    );
  });
}
