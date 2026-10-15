import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/cart/screens/cart_screen.dart';
import 'package:e_commerc_mobile_app/features/checkout/screens/checkout_screen.dart';
import 'package:e_commerc_mobile_app/features/checkout/screens/order_success_screen.dart';
import 'package:e_commerc_mobile_app/features/products/models/product_model.dart';

void main() {
  const testProduct1 = ProductModel(
    id: 101,
    name: 'UltraBook Pro 15" M2 Laptop',
    description: 'High performance laptop with retina display.',
    price: 120.00,
    rating: 4.9,
    reviewCount: 312,
    categoryId: 1,
    imageUrl: '',
  );

  const testProduct2 = ProductModel(
    id: 102,
    name: 'Wireless 3-in-1 Fast Charging Station',
    description: 'Mag-safe compatible fast wireless dock.',
    price: 45.00,
    rating: 4.6,
    reviewCount: 88,
    categoryId: 1,
    imageUrl: '',
  );

  group('CartScreen Modernization Tests', () {
    testWidgets('renders empty cart state with Start Shopping action', (
      WidgetTester tester,
    ) async {
      final cartProvider = CartProvider();
      var explored = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: CartScreen(onExplore: () => explored = true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Empty cart headers
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Start Shopping'), findsOneWidget);

      // Tap "Start Shopping"
      await tester.tap(find.text('Start Shopping'));
      await tester.pump();
      expect(explored, isTrue);
    });

    testWidgets('renders populated cart with item cards, progress, and totals', (
      WidgetTester tester,
    ) async {
      final cartProvider = CartProvider();
      cartProvider.addItem(testProduct2, quantity: 1); // $45.00 (< $100 -> $10 fee)

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Cart item details
      expect(find.text(testProduct2.name), findsOneWidget);
      expect(find.text('\$45.00'), findsWidgets); // item price and subtotal

      // Free shipping remaining calculation: $100 - $45 = $55.00
      expect(
        find.text('Add \$55.00 more for FREE shipping'),
        findsOneWidget,
      );

      // Order Summary
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('\$10.00'), findsOneWidget); // $10 delivery fee
      expect(find.text('\$55.00'), findsWidgets); // grand total $45 + $10 = $55

      // Stepper increments quantity
      await tester.tap(find.byKey(const Key('cart_increment_0')));
      await tester.pump();

      expect(cartProvider.items.first.quantity, 2);
      expect(find.text('\$90.00'), findsWidgets); // 2 x $45 = $90
      expect(find.text('Add \$10.00 more for FREE shipping'), findsOneWidget);

      // Stepper decrements quantity back to 1
      await tester.tap(find.byKey(const Key('cart_decrement_0')));
      await tester.pump();

      expect(cartProvider.items.first.quantity, 1);
      expect(find.text('\$45.00'), findsWidgets);

      // Single item removal
      await tester.tap(find.byKey(const Key('remove_cart_item_0')));
      await tester.pumpAndSettle();

      expect(cartProvider.isEmpty, isTrue);
      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('shows unlocked FREE delivery banner when subtotal >= \$100', (
      WidgetTester tester,
    ) async {
      final cartProvider = CartProvider();
      cartProvider.addItem(testProduct1, quantity: 1); // $120.00 (>= $100 -> FREE)

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('🎉 You unlocked FREE Delivery!'), findsOneWidget);
      expect(find.text('FREE'), findsOneWidget);
      expect(find.text('\$120.00'), findsWidgets);
    });

    testWidgets('renders cleanly on narrow screens (320px width) in Dark Mode', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cartProvider = CartProvider();
      cartProvider.addItem(testProduct1, quantity: 1);

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(testProduct1.name), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
    });
  });

  group('CheckoutScreen Modernization Tests', () {
    testWidgets('renders all 5 checkout sections clearly', (
      WidgetTester tester,
    ) async {
      final cartProvider = CartProvider();
      cartProvider.addItem(testProduct1, quantity: 1); // $120.00

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Delivery Address
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);

      // 2. Order Items
      expect(find.text('Order Items (1)'), findsOneWidget);
      expect(find.text(testProduct1.name), findsOneWidget);

      // 3. Shipping Method
      expect(find.text('Shipping Method'), findsOneWidget);
      expect(find.text('Standard Delivery'), findsOneWidget);
      expect(find.text('Express Fast Delivery'), findsOneWidget);

      // 4. Payment Method
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('ABA / KHQR Pay'), findsOneWidget);
      expect(find.text('Credit / Debit Card'), findsOneWidget);
      expect(find.text('Cash on Delivery (COD)'), findsOneWidget);

      // 5. Price Breakdown
      expect(find.text('Price Breakdown'), findsOneWidget);
      expect(find.text('Cart Subtotal'), findsOneWidget);
      expect(find.text('Shipping Fee'), findsOneWidget);

      // Sticky Place Order Bar
      expect(find.text('Place Order • \$120.00'), findsOneWidget);
    });

    testWidgets('switching shipping method updates shipping fee and total', (
      WidgetTester tester,
    ) async {
      final cartProvider = CartProvider();
      cartProvider.addItem(testProduct1, quantity: 1); // $120.00 (Standard = FREE)

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Place Order • \$120.00'), findsOneWidget);

      // Tap Express Fast Delivery (index 1 -> +$5.00 surcharge)
      await tester.tap(find.byKey(const Key('shipping_method_1')));
      await tester.pump();

      // Total updates to $125.00 ($120.00 + $5.00)
      expect(find.text('Place Order • \$125.00'), findsOneWidget);
      expect(find.text('\$5.00'), findsWidgets);
    });

    testWidgets('switching delivery address via bottom sheet updates selection', (
      WidgetTester tester,
    ) async {
      final cartProvider = CartProvider();
      cartProvider.addItem(testProduct1, quantity: 1);

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Change"
      await tester.tap(find.byKey(const Key('change_address_button')));
      await tester.pumpAndSettle();

      // Verify modal bottom sheet opened with available addresses
      expect(find.text('Select Delivery Address'), findsOneWidget);
      expect(find.text('Office / University'), findsOneWidget);

      // Tap Office / University option
      await tester.tap(find.byKey(const Key('address_option_2')));
      await tester.pumpAndSettle();

      // Modal closed, address card updated to Office / University
      expect(find.text('Select Delivery Address'), findsNothing);
      expect(find.text('Office / University'), findsOneWidget);
    });

    testWidgets('placing order clears cart and navigates to OrderSuccessScreen', (
      WidgetTester tester,
    ) async {
      final cartProvider = CartProvider();
      cartProvider.addItem(testProduct1, quantity: 1);

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Place Order
      await tester.tap(find.byKey(const Key('place_order_button')));
      await tester.pump(); // Enter loading state

      // Advance simulated timer
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Verify cart was cleared
      expect(cartProvider.isEmpty, isTrue);

      // Verify OrderSuccessScreen was pushed
      expect(find.byType(OrderSuccessScreen), findsOneWidget);
      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.text('\$120.00'), findsOneWidget);
      expect(find.text('ABA / KHQR Pay'), findsOneWidget);
    });
  });

  group('OrderSuccessScreen Modernization Tests', () {
    testWidgets('renders authentic confirmation details without fake estimates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderSuccessScreen(
            grandTotal: 125.00,
            paymentMethod: 'Credit / Debit Card',
            addressCity: 'Phnom Penh, Cambodia',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header and message
      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Genuine fields
      expect(find.text('Total Paid'), findsOneWidget);
      expect(find.text('\$125.00'), findsOneWidget);
      expect(find.text('Credit / Debit Card'), findsOneWidget);
      expect(find.text('Phnom Penh, Cambodia'), findsOneWidget);
      expect(find.text('Confirmed & Processing'), findsOneWidget);

      // Verify no fake random ID or fake delivery estimate
      expect(find.textContaining('BP-'), findsNothing);
      expect(find.textContaining('Business Days'), findsNothing);

      // Action button
      expect(find.text('Continue Shopping'), findsOneWidget);
    });

    testWidgets('renders cleanly in Dark Mode and narrow screen (320px)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const OrderSuccessScreen(
            grandTotal: 55.00,
            paymentMethod: 'Cash on Delivery (COD)',
            addressCity: 'Phnom Penh, Cambodia',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.text('\$55.00'), findsOneWidget);
    });
  });
}
