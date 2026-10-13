import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/features/categories/models/category_model.dart';
import 'package:e_commerc_mobile_app/features/categories/screens/category_products_screen.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';

void main() {
  testWidgets(
    'CategoryProductsScreen lazy loads below the fold (6 initially, loads more on scroll)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      const allCategory = CategoryModel(
        id: 0,
        name: 'All Items',
        icon: '🛍️',
        itemCount: 25,
        imageUrl: '',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductProvider>.value(
              value: productProvider,
            ),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ],
          child: const MaterialApp(
            home: CategoryProductsScreen(category: allCategory),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Total products is 25
      expect(productProvider.allProducts.length, 25);

      // Verify the 1st product is in the tree, but the 8th product is not loaded yet
      expect(find.text(productProvider.allProducts[0].name), findsOneWidget);
      expect(find.text(productProvider.allProducts[7].name), findsNothing);

      // Scroll down to trigger lazy loading threshold
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pump();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pump();

      // Advance past simulated loadMore delay
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // The 8th product is now loaded in the below-the-fold batch
      expect(find.text(productProvider.allProducts[7].name), findsOneWidget);
    },
  );
}
