import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/products/screens/product_detail_screen.dart';

void main() {
  testWidgets(
    'ProductDetailScreen syncs favorite state with ProductProvider allProducts',
    (WidgetTester tester) async {
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      // Filter productProvider to category 2
      productProvider.selectCategory(2);

      // Open a product from category 1 (which is not in filteredProducts)
      final testProduct = productProvider.allProducts.firstWhere(
        (p) => p.categoryId == 1,
      );
      expect(testProduct.isFavorite, isFalse);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(
              value: productProvider,
            ),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ],
          child: MaterialApp(home: ProductDetailScreen(product: testProduct)),
        ),
      );

      await tester.pumpAndSettle();

      // Product title rendered
      expect(find.text(testProduct.name), findsOneWidget);

      // Initially not favorite
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      // Tap favorite button
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pump();

      // Verify provider has item favorited
      expect(
        productProvider.allProducts
            .firstWhere((p) => p.id == testProduct.id)
            .isFavorite,
        isTrue,
      );

      // Verify UI updated to favorite icon
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    },
  );
}
