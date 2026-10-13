import 'package:flutter/foundation.dart';
import '../../products/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

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
  }

  // Increase quantity of item by 1
  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Decrease quantity by 1, or remove item if quantity reaches 0
  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Remove item completely from cart
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  // Empty the entire cart (e.g. after successful order placement)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
