import 'package:flutter/foundation.dart';
import '../../products/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalItemsCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Free shipping on orders over $100, otherwise $10 flat delivery fee
  double get shippingFee => (subtotal >= 100.0 || _items.isEmpty) ? 0.0 : 10.0;

  double get grandTotal => subtotal + shippingFee;

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

  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

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

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
