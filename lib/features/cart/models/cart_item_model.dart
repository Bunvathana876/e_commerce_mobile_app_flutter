import '../../products/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  final String variant;
  int quantity;

  CartItemModel({
    required this.product,
    this.variant = 'Standard',
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  CartItemModel copyWith({
    ProductModel? product,
    String? variant,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'variant': variant,
      'price': product.price,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}
