import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerc_mobile_app/app/routes.dart';
import 'package:e_commerc_mobile_app/core/theme/app_theme.dart';
import 'package:e_commerc_mobile_app/features/auth/providers/auth_provider.dart';
import 'package:e_commerc_mobile_app/features/cart/providers/cart_provider.dart';
import 'package:e_commerc_mobile_app/features/orders/models/order_model.dart';
import 'package:e_commerc_mobile_app/features/orders/providers/order_provider.dart';
import 'package:e_commerc_mobile_app/features/orders/screens/order_detail_screen.dart';
import 'package:e_commerc_mobile_app/features/orders/screens/order_history_screen.dart';
import 'package:e_commerc_mobile_app/features/products/providers/product_provider.dart';
import 'package:e_commerc_mobile_app/features/profile/screens/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testDate = DateTime(2026, 4, 15, 10, 30);

  final testOrder1 = OrderModel(
    id: 1001,
    userId: 1,
    status: 'processing',
    subtotal: 120.00,
    shippingFee: 0.00,
    total: 120.00,
    paymentMethod: 'ABA / KHQR Pay',
    paymentStatus: 'paid',
    shippingAddress: 'Street 2004, Phnom Penh, Cambodia',
    createdAt: testDate,
    items: const [
      OrderItemModel(
        id: 1,
        orderId: 1001,
        productId: 101,
        productName: 'UltraBook Pro 15" M2 Laptop',
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300',
        price: 120.00,
        quantity: 1,
        subtotal: 120.00,
      ),
    ],
  );

  final testOrder2 = OrderModel(
    id: 1002,
    userId: 1,
    status: 'delivered',
    subtotal: 45.00,
    shippingFee: 10.00,
    total: 55.00,
    paymentMethod: 'Cash on Delivery (COD)',
    paymentStatus: 'paid',
    shippingAddress: 'Monivong Blvd, Phnom Penh, Cambodia',
    createdAt: testDate.subtract(const Duration(days: 3)),
    items: const [
      OrderItemModel(
        id: 2,
        orderId: 1002,
        productId: 102,
        productName: 'Wireless 3-in-1 Fast Charging Station',
        imageUrl: '',
        price: 45.00,
        quantity: 1,
        subtotal: 45.00,
      ),
    ],
  );

  group('OrderModel and OrderItemModel Tests', () {
    test('parses from JSON correctly with robust type coercion', () {
      final jsonMap = {
        'id': '2001', // string id coerced to int
        'user_id': 1,
        'status': 'shipped',
        'subtotal': '80', // string coerced to double
        'shipping_fee': 5, // int coerced to double
        'total': 85.0,
        'payment_method': 'Credit Card',
        'payment_status': 'paid',
        'shipping_address': 'Phnom Penh',
        'created_at': '2026-04-10T12:00:00Z',
        'items': [
          {
            'id': 10,
            'order_id': 2001,
            'product_id': 55,
            'product_name': 'Mechanical Keyboard',
            'product_image': '',
            'price': '80.00',
            'quantity': '1',
          }
        ],
      };

      final order = OrderModel.fromJson(jsonMap);

      expect(order.id, 2001);
      expect(order.formattedOrderId, '#2001');
      expect(order.status, 'shipped');
      expect(order.isActive, isTrue);
      expect(order.isPaid, isTrue);
      expect(order.subtotal, 80.0);
      expect(order.shippingFee, 5.0);
      expect(order.total, 85.0);
      expect(order.items.length, 1);
      expect(order.items.first.productName, 'Mechanical Keyboard');
      expect(order.items.first.subtotal, 80.0);
    });

    test('serializes to JSON and round-trips accurately', () {
      final jsonMap = testOrder1.toJson();
      final roundTrip = OrderModel.fromJson(jsonMap);

      expect(roundTrip.id, testOrder1.id);
      expect(roundTrip.status, testOrder1.status);
      expect(roundTrip.total, testOrder1.total);
      expect(roundTrip.paymentMethod, testOrder1.paymentMethod);
      expect(roundTrip.items.length, testOrder1.items.length);
      expect(roundTrip.items.first.productName, testOrder1.items.first.productName);
    });

    test('isActive returns false for delivered and cancelled orders', () {
      expect(testOrder1.isActive, isTrue); // 'processing'
      expect(testOrder2.isActive, isFalse); // 'delivered'
      final cancelledOrder = testOrder1.copyWith(status: 'cancelled');
      expect(cancelledOrder.isActive, isFalse);
    });
  });

  group('OrderProvider Persistence & State Management Tests', () {
    test('initializes empty when no cached orders exist in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = OrderProvider(initialPrefs: prefs);

      expect(provider.orders, isEmpty);
      expect(provider.activeOrdersCount, 0);
      expect(provider.isLoading, isFalse);
    });

    test('records order and persists to SharedPreferences cache', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = OrderProvider(initialPrefs: prefs);

      provider.recordOrder(testOrder1);

      expect(provider.orders.length, 1);
      expect(provider.orders.first.id, 1001);
      expect(provider.activeOrdersCount, 1);

      // Verify cached in SharedPreferences
      final rawCache = prefs.getString('user_orders_cache');
      expect(rawCache, isNotNull);
      final decoded = jsonDecode(rawCache!) as List;
      expect(decoded.length, 1);
      expect(decoded.first['id'], 1001);
    });

    test('restores cached orders on fresh OrderProvider instantiation', () async {
      final cacheData = jsonEncode([testOrder1.toJson(), testOrder2.toJson()]);
      SharedPreferences.setMockInitialValues({'user_orders_cache': cacheData});
      final prefs = await SharedPreferences.getInstance();

      final provider = OrderProvider(initialPrefs: prefs);

      expect(provider.orders.length, 2);
      expect(provider.orders[0].id, 1001);
      expect(provider.orders[1].id, 1002);
      // testOrder1 is processing (active), testOrder2 is delivered (inactive) -> 1 active
      expect(provider.activeOrdersCount, 1);
    });

    test('clearOrders empties in-memory list and removes persistent cache', () async {
      final cacheData = jsonEncode([testOrder1.toJson()]);
      SharedPreferences.setMockInitialValues({'user_orders_cache': cacheData});
      final prefs = await SharedPreferences.getInstance();
      final provider = OrderProvider(initialPrefs: prefs);

      expect(provider.orders.length, 1);
      await provider.clearOrders();

      expect(provider.orders, isEmpty);
      expect(provider.activeOrdersCount, 0);
      expect(prefs.containsKey('user_orders_cache'), isFalse);
    });
  });

  group('OrderHistoryScreen Widget Tests', () {
    testWidgets('renders truthful empty state when no orders exist', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final orderProvider = OrderProvider(initialPrefs: prefs);

      await tester.pumpWidget(
        ChangeNotifierProvider<OrderProvider>.value(
          value: orderProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const OrderHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('No Orders Yet'), findsOneWidget);
      expect(find.text('Start Shopping'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('renders order cards with authentic details and navigates to details', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final orderProvider = OrderProvider(initialPrefs: prefs);
      orderProvider.recordOrder(testOrder1);
      orderProvider.recordOrder(testOrder2);

      await tester.pumpWidget(
        ChangeNotifierProvider<OrderProvider>.value(
          value: orderProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const OrderHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);

      // Order 1001 cards details
      expect(find.text('#1001'), findsOneWidget);
      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('\$120.00'), findsOneWidget);
      expect(find.textContaining('ABA / KHQR Pay'), findsOneWidget);

      // Order 1002 cards details
      expect(find.text('#1002'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('\$55.00'), findsOneWidget);

      // Tap order 1001 to navigate to detail
      await tester.tap(find.text('#1001'));
      await tester.pumpAndSettle();

      expect(find.byType(OrderDetailScreen), findsOneWidget);
      expect(find.text('Order #1001'), findsOneWidget);
    });

    testWidgets('renders cleanly on narrow 320px screens in Dark Mode', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final orderProvider = OrderProvider(initialPrefs: prefs);
      orderProvider.recordOrder(testOrder1);

      await tester.pumpWidget(
        ChangeNotifierProvider<OrderProvider>.value(
          value: orderProvider,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const OrderHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('#1001'), findsOneWidget);
      expect(find.text('\$120.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('OrderDetailScreen Widget Tests', () {
    testWidgets('renders comprehensive order details without fake tracking', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: OrderDetailScreen(order: testOrder1),
        ),
      );

      await tester.pumpAndSettle();

      // Header
      expect(find.text('Order #1001'), findsOneWidget);
      expect(find.text('Processing'), findsWidgets);

      // 4-stage tracking timeline
      expect(find.text('Processing Order'), findsOneWidget);
      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Processing'), findsWidgets);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      // Truthful tracking notice (no fake live GPS)
      expect(
        find.textContaining('Live GPS tracking is not available'),
        findsOneWidget,
      );

      // Items section
      expect(find.text('Order Items (1)'), findsOneWidget);
      expect(find.text('UltraBook Pro 15" M2 Laptop'), findsOneWidget);
      expect(find.text('Qty: 1 × \$120.00'), findsOneWidget);

      // Delivery & Payment info
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Street 2004, Phnom Penh, Cambodia'), findsOneWidget);
      expect(find.text('Payment Information'), findsOneWidget);
      expect(find.text('ABA / KHQR Pay'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);

      // Price breakdown
      await tester.scrollUntilVisible(find.text('Order Summary'), 150);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Shipping Fee'), findsOneWidget);
      expect(find.text('Total Paid'), findsOneWidget);
      expect(find.text('FREE'), findsOneWidget); // shippingFee = 0.00

      // Action button
      await tester.scrollUntilVisible(find.text('Continue Shopping'), 150);
      expect(find.text('Continue Shopping'), findsOneWidget);
    });

    testWidgets('renders delivered order cleanly in Dark Mode at 320px width', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: OrderDetailScreen(order: testOrder2),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Order #1002'), findsOneWidget);
      expect(find.text('Delivered'), findsWidgets);

      await tester.scrollUntilVisible(find.text('\$10.00'), 150);
      expect(find.text('\$10.00'), findsOneWidget); // shipping fee
      expect(find.text('\$55.00'), findsOneWidget); // total
      expect(tester.takeException(), isNull);
    });
  });

  group('ProfileScreen Order Integration & Modernization Tests', () {
    testWidgets('displays authentic active orders count from OrderProvider', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final orderProvider = OrderProvider(initialPrefs: prefs);
      orderProvider.recordOrder(testOrder1); // 1 active order

      final authProvider = AuthProvider();
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
            ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Orders Stat Card and tile display active order count
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('1 Active'), findsWidgets);

      // Record another active order
      final testOrder3 = testOrder1.copyWith(id: 1003, status: 'shipped');
      orderProvider.recordOrder(testOrder3);
      await tester.pumpAndSettle();

      expect(find.text('2 Active'), findsWidgets);
    });

    testWidgets('opens Shipping Addresses and Payment Methods modal bottom sheets', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final orderProvider = OrderProvider(initialPrefs: prefs);
      final authProvider = AuthProvider();
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
            ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open Shipping Addresses
      final addressTile = find.text('Shipping Addresses');
      await tester.scrollUntilVisible(addressTile, 150);
      await tester.tap(addressTile);
      await tester.pumpAndSettle();

      expect(find.text('Shipping Addresses'), findsWidgets);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);

      // Close sheet
      Navigator.of(tester.element(find.text('DEFAULT'))).pop();
      await tester.pumpAndSettle();

      // Open Payment Methods
      final paymentTile = find.text('Payment Methods');
      await tester.scrollUntilVisible(paymentTile, 150);
      await tester.tap(paymentTile);
      await tester.pumpAndSettle();

      expect(find.text('Supported Payment Methods'), findsOneWidget);
      expect(find.text('ABA KHQR Pay'), findsOneWidget);
      expect(find.text('Cash on Delivery (COD)'), findsOneWidget);

      // Close sheet
      Navigator.of(tester.element(find.text('Supported Payment Methods'))).pop();
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to OrderHistoryScreen when tapping My Orders', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final orderProvider = OrderProvider(initialPrefs: prefs);
      final authProvider = AuthProvider();
      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
            ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'My Orders' tile
      final myOrdersTile = find.text('My Orders');
      await tester.scrollUntilVisible(myOrdersTile, 150);
      await tester.tap(myOrdersTile);
      await tester.pumpAndSettle();

      expect(find.byType(OrderHistoryScreen), findsOneWidget);
      expect(find.text('My Orders'), findsWidgets);
    });

    testWidgets('logout dialog clears auth and cached orders', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final orderProvider = OrderProvider(initialPrefs: prefs);
      orderProvider.recordOrder(testOrder1);

      final authProvider = AuthProvider(initialPrefs: prefs);
      await authProvider.login('student@example.com', 'password123');

      final productProvider = ProductProvider();
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
            ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
            ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            routes: {
              AppRoutes.welcome: (ctx) => const Scaffold(body: Text('Welcome Screen')),
            },
            home: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Log Out button in Profile screen
      final logoutButton = find.text('Log Out');
      await tester.scrollUntilVisible(logoutButton, 200);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Dialog is open
      expect(
        find.text('Are you sure you want to sign out of Blue Panda? You will need to log in again to view your saved addresses and orders.'),
        findsOneWidget,
      );

      // Confirm Logout inside dialog using widgetWithText
      final dialogLogoutBtn = find.widgetWithText(ElevatedButton, 'Log Out');
      await tester.tap(dialogLogoutBtn);
      await tester.pumpAndSettle();

      // Auth is logged out
      expect(authProvider.isAuthenticated, isFalse);
      // Orders are cleared
      expect(orderProvider.orders, isEmpty);
      // Navigated to Welcome
      expect(find.text('Welcome Screen'), findsOneWidget);
    });
  });
}
