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

  // Line item total calculation
  double get totalPrice => product.price * quantity;

  // Clone cart item with updated count or variant
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

  // Parse cart line item from JSON map
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : ProductModel(
              id: (json['product_id'] as num?)?.toInt() ?? 0,
              name: json['product_name'] as String? ?? 'Product',
              description: '',
              price: (json['price'] as num?)?.toDouble() ?? 0.0,
              rating: 5.0,
              reviewCount: 0,
              categoryId: 1,
              imageUrl: json['image_url'] as String? ?? '',
            ),
      variant: json['variant'] as String? ?? 'Standard',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  // Convert line item to JSON map
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
