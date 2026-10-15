import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../products/models/product_model.dart';
import '../models/cart_item_model.dart';
import '../services/cart_api_service.dart';

class CartProvider extends ChangeNotifier {
  final CartApiService _cartApiService;
  final List<CartItemModel> _items = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  CartProvider({CartApiService? cartApiService})
      : _cartApiService = cartApiService ?? CartApiService();

  // Read-only list of items in the cart
  List<CartItemModel> get items => List.unmodifiable(_items);

  // Check if cart has zero items
  bool get isEmpty => _items.isEmpty;

  // Total quantity of all units in the cart
  int get totalItemsCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Subtotal before shipping fees
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Free shipping on orders over $100, otherwise $10 flat delivery fee
  double get shippingFee => (subtotal >= 100.0 || _items.isEmpty) ? 0.0 : 10.0;

  // Final grand total (subtotal + shipping)
  double get grandTotal => subtotal + shippingFee;

  // Fetch cart from remote API when logged in
  Future<void> loadRemoteCart() async {
    if (!ApiClient.instance.isAuthenticated) return;
    _isLoading = true;
    try {
      final remoteItems = await _cartApiService.getCart();
      if (remoteItems.isNotEmpty) {
        _items.clear();
        _items.addAll(remoteItems);
      }
    } catch (e) {
      debugPrint('CartProvider loadRemoteCart note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a product or increase its quantity if matching variant exists
  void addItem(
    ProductModel product, {
    String variant = 'Standard',
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.variant == variant,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItemModel(product: product, variant: variant, quantity: quantity),
      );
    }
    notifyListeners();

    // Sync with backend if authenticated
    if (ApiClient.instance.isAuthenticated) {
      _cartApiService
          .addToCart(
            productId: product.id,
            quantity: quantity,
            variant: variant,
          )
          .catchError((e) {
            debugPrint('Failed to sync added cart item with backend: $e');
            return CartItemModel(product: product);
          });
    }
  }

  // Increase quantity of item by 1
  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
      final item = _items[index];
      notifyListeners();

      if (ApiClient.instance.isAuthenticated) {
        _cartApiService
            .updateQuantity(
              productId: item.product.id,
              quantity: item.quantity,
            )
            .catchError((e) {
              debugPrint('Failed to sync incremented cart item: $e');
            });
      }
    }
  }

  // Decrease quantity by 1, or remove item if quantity reaches 0
  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        notifyListeners();

        if (ApiClient.instance.isAuthenticated) {
          _cartApiService
              .updateQuantity(
                productId: item.product.id,
                quantity: item.quantity,
              )
              .catchError((e) {
                debugPrint('Failed to sync decremented cart item: $e');
              });
        }
      } else {
        _items.removeAt(index);
        notifyListeners();

        if (ApiClient.instance.isAuthenticated) {
          _cartApiService
              .removeFromCart(item.product.id)
              .catchError((e) {
                debugPrint('Failed to sync removed cart item: $e');
              });
        }
      }
    }
  }

  // Remove item completely from cart
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      final item = _items.removeAt(index);
      notifyListeners();

      if (ApiClient.instance.isAuthenticated) {
        _cartApiService.removeFromCart(item.product.id).catchError((e) {
          debugPrint('Failed to sync removed cart item: $e');
        });
      }
    }
  }

  // Empty the entire cart (e.g. after successful order placement)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
