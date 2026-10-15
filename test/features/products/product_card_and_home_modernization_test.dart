import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/categories/providers/category_provider.dart';
import 'package:e_commerc_mobile_app/features/home/screens/home_screen.dart';
import 'package:e_commerc_mobile_app/features/products/models/product_model.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/features/products/widgets/product_card.dart';

void main() {
  const testProduct = ProductModel(
    id: 999,
    name: 'Pro Wireless Studio Sound Headphones with Active Noise Cancellation',
    description: 'Test description for premium headphones',
    price: 199.99,
    originalPrice: 249.99,
    discountPercent: 20,
    rating: 4.8,
    reviewCount: 312,
    categoryId: 1,
    imageUrl: '',
    isFavorite: false,
  );

  group('ProductCard Widget Tests', () {
    testWidgets('renders all product information cleanly in Light Mode', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      var favoriteToggled = false;
      var addedToCart = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 170,
                height: 280,
                child: ProductCard(
                  product: testProduct,
                  onTap: () => tapped = true,
                  onToggleFavorite: () => favoriteToggled = true,
                  onAddToCart: () => addedToCart = true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title & Price verification
      expect(find.text(testProduct.name), findsOneWidget);
      expect(find.text('\$199.99'), findsOneWidget);
      expect(find.text('\$249.99'), findsOneWidget);

      // Discount & Rating badges
      expect(find.text('-20%'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(312)'), findsOneWidget);

      // Favorite & Add icons
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Tap actions
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pump();
      expect(favoriteToggled, isTrue);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(addedToCart, isTrue);

      await tester.tap(find.text(testProduct.name));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders favorite state and Dark Mode surfaces properly', (
      WidgetTester tester,
    ) async {
      final favoritedProduct = testProduct.copyWith(isFavorite: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 170,
                height: 280,
                child: ProductCard(
                  product: favoritedProduct,
                  onTap: () {},
                  onToggleFavorite: () {},
                  onAddToCart: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Favorite active state
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    });

    testWidgets('does not overflow on narrow screens (320px width)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.all(10),
              children: [
                ProductCard(
                  product: testProduct,
                  onTap: () {},
                  onToggleFavorite: () {},
                  onAddToCart: () {},
                ),
                ProductCard(
                  product: testProduct.copyWith(isFavorite: true),
                  onTap: () {},
                  onToggleFavorite: () {},
                  onAddToCart: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no RenderFlex errors occurred
      expect(tester.takeException(), isNull);
      expect(find.text(testProduct.name), findsNWidgets(2));
    });
  });

  group('HomeScreen Modernization Tests', () {
    testWidgets('Search input clear button resets query', (
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

      // Type a search query into search field
      await tester.enterText(
        find.widgetWithText(TextField, 'Search products, brands, gear...'),
        'laptop',
      );
      await tester.pumpAndSettle();

      expect(productProvider.searchQuery, equals('laptop'));
      expect(find.byKey(const Key('search_clear_button')), findsOneWidget);

      // Tap clear icon
      await tester.tap(find.byKey(const Key('search_clear_button')));
      await tester.pumpAndSettle();

      expect(productProvider.searchQuery, isEmpty);
      expect(find.byKey(const Key('search_clear_button')), findsNothing);
    });

    testWidgets('Tapping tune icon opens Sort modal sheet and applies sorting', (
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

      // Tap tune icon in search bar
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      // Verify Sort sheet opened
      expect(find.text('Sort Products'), findsOneWidget);
      expect(find.text('Price: Low to High'), findsOneWidget);
      expect(find.text('Price: High to Low'), findsOneWidget);
      expect(find.text('Customer Rating'), findsOneWidget);

      // Select 'Price: Low to High'
      await tester.tap(find.text('Price: Low to High'));
      await tester.pumpAndSettle();

      // Verify provider sort is updated
      expect(productProvider.sortBy, equals('price_low'));

      // Verify active filter chip displays sort
      expect(find.text('Sort: Price: Low to High'), findsOneWidget);
    });

    testWidgets('Empty search shows modernized empty state with reset button', (
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

      // Search for something that returns no products
      productProvider.setSearchQuery('xyznonexistentproductquery123');
      await tester.pumpAndSettle();

      // Empty state elements are shown
      expect(find.text('No products found matching your search.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.text('Reset Filters'), findsOneWidget);

      // Tapping Reset Filters clears search and restores catalog
      await tester.tap(find.text('Reset Filters'));
      await tester.pumpAndSettle();

      expect(productProvider.searchQuery, isEmpty);
      expect(productProvider.displayedProducts.length, equals(6));
    });
  });
}
