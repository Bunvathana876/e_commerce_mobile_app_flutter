import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/products/models/product_model.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/features/products/screens/product_detail_screen.dart';

void main() {
  const testProductWithDiscount = ProductModel(
    id: 999,
    name: 'Pro Wireless Studio Sound Headphones with Active Noise Cancellation',
    description:
        'Engineered for audiophiles and studio producers, these over-ear headphones deliver ultra-low distortion, high-resolution audio streaming, adaptive noise canceling, and up to 40 hours of continuous playback on a single quick-charge cycle.',
    price: 199.99,
    originalPrice: 249.99,
    discountPercent: 20,
    rating: 4.8,
    reviewCount: 312,
    categoryId: 6, // Audio & Sound
    imageUrl: '',
    isFavorite: false,
  );

  const testProductSimple = ProductModel(
    id: 888,
    name: 'Everyday Cotton T-Shirt',
    description: 'Comfortable everyday basic tee.',
    price: 25.00,
    rating: 4.5,
    reviewCount: 50,
    categoryId: 2, // Fashion & Clothing
    imageUrl: '',
    isFavorite: false,
  );

  group('ProductDetailScreen Modernization Tests', () {
    testWidgets('renders all authentic product information in Light Mode', (
      WidgetTester tester,
    ) async {
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProductDetailScreen(product: testProductWithDiscount),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Product Title and Price
      expect(find.text(testProductWithDiscount.name), findsOneWidget);
      expect(find.text('\$199.99'), findsOneWidget);
      expect(find.text('\$249.99'), findsOneWidget);
      expect(find.text('Save \$50.00'), findsOneWidget);
      expect(find.text('-20% OFF'), findsOneWidget);

      // Real category lookup (Audio & Sound)
      expect(find.text('Audio & Sound'), findsWidgets);

      // Real specs row
      expect(find.text('#BP-999'), findsOneWidget);
      expect(find.text('Free Shipping'), findsWidgets);

      // Description and Show more toggle
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Show more'), findsOneWidget);

      // Scroll to "Show more" and tap
      await tester.ensureVisible(find.text('Show more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();
      expect(find.text('Show less'), findsOneWidget);

      // Shopping Guarantees
      expect(find.text('Shopping Guarantees'), findsOneWidget);
      expect(find.text('100% Genuine'), findsOneWidget);
      expect(find.text('30-Day Return'), findsOneWidget);

      // Customer Ratings section
      expect(find.text('Customer Ratings'), findsWidgets);
      expect(find.text('312 Verified Ratings'), findsOneWidget);

      // Sticky Purchase Bar initial total: $199.99
      expect(find.text('Add • \$199.99'), findsOneWidget);
      expect(find.byKey(const Key('product_quantity_text')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('product_quantity_text'))).data,
        '1',
      );
    });

    testWidgets('Quantity stepper increments, decrements, and prevents < 1', (
      WidgetTester tester,
    ) async {
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProductDetailScreen(product: testProductWithDiscount),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final qtyFinder = find.byKey(const Key('product_quantity_text'));

      // Try decrementing when quantity is 1 -> remains 1
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(tester.widget<Text>(qtyFinder).data, '1');
      expect(find.text('Add • \$199.99'), findsOneWidget);

      // Increment to 2 -> total updates to $399.98
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(tester.widget<Text>(qtyFinder).data, '2');
      expect(find.text('Add • \$399.98'), findsOneWidget);

      // Increment to 3 -> total updates to $599.97
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(tester.widget<Text>(qtyFinder).data, '3');
      expect(find.text('Add • \$599.97'), findsOneWidget);

      // Decrement back to 2 -> total updates to $399.98
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(tester.widget<Text>(qtyFinder).data, '2');
      expect(find.text('Add • \$399.98'), findsOneWidget);
    });

    testWidgets('Add to Cart adds item to CartProvider and displays feedback', (
      WidgetTester tester,
    ) async {
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProductDetailScreen(product: testProductWithDiscount),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select quantity = 2
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      // Tap Add to Cart button
      await tester.tap(find.text('Add • \$399.98'));
      await tester.pump(); // Start SnackBar animation

      // Verify item was added to CartProvider with quantity 2
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.product.id, testProductWithDiscount.id);
      expect(cartProvider.items.first.quantity, 2);

      // Verify SnackBar feedback is visible
      expect(
        find.textContaining('Added 2 × ${testProductWithDiscount.name} to cart!'),
        findsOneWidget,
      );
    });

    testWidgets('Renders properly in Dark Mode without crashing', (
      WidgetTester tester,
    ) async {
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProductDetailScreen(product: testProductWithDiscount),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(testProductWithDiscount.name), findsOneWidget);
      expect(find.text('\$199.99'), findsOneWidget);
    });

    testWidgets('Renders clean layout on narrow screens (320px width)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProductDetailScreen(product: testProductWithDiscount),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(testProductWithDiscount.name), findsOneWidget);
      expect(find.byType(ProductDetailScreen), findsOneWidget);
    });

    testWidgets('Does not display discount badges when product has no discount', (
      WidgetTester tester,
    ) async {
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProductDetailScreen(product: testProductSimple),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Discount indicators should not be present
      expect(find.textContaining('OFF'), findsNothing);
      expect(find.textContaining('Save \$'), findsNothing);

      // Price displayed
      expect(find.text('\$25.00'), findsOneWidget);
      expect(find.text('Add • \$25.00'), findsOneWidget);
      expect(find.text('\$10 Delivery'), findsOneWidget); // < $100
    });
  });
}
