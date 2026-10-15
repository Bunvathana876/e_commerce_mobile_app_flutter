import 'package:flutter/foundation.dart';

/// Represents an item within a placed order.
@immutable
class OrderItemModel {
  final int id;
  final int orderId;
  final int? productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final String? imageUrl;
  final DateTime? createdAt;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.imageUrl,
    this.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final price = _toDouble(json['price']);
      final qty = json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse('${json['quantity']}') ?? 1;
      final subtotal = json['subtotal'] != null
          ? _toDouble(json['subtotal'])
          : (price * qty);

      return OrderItemModel(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        orderId: json['order_id'] is int
            ? json['order_id'] as int
            : int.tryParse('${json['order_id']}') ?? 0,
        productId: json['product_id'] != null
            ? (json['product_id'] is int
                ? json['product_id'] as int
                : int.tryParse('${json['product_id']}'))
            : null,
        productName: (json['product_name'] ?? json['name'] ?? 'Product').toString(),
        price: price,
        quantity: qty,
        subtotal: subtotal,
        imageUrl: (json['image_url'] ?? json['product_image'])?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );
    }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Represents a customer order in Blue Panda.
@immutable
class OrderModel {
  final int id;
  final int userId;
  final String status; // 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
  final double subtotal;
  final double discountAmount;
  final String? couponCode;
  final double shippingFee;
  final double total;
  final String paymentMethod;
  final String paymentStatus; // 'unpaid', 'paid', 'refunded'
  final String shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.couponCode,
    required this.shippingFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  /// Human-readable Order ID formatted with hash (e.g. #1001)
  String get formattedOrderId => '#${id.toString().padLeft(4, '0')}';

  /// Whether the order has been paid
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  /// Whether the order is currently active (not delivered or cancelled)
  bool get isActive {
    final s = status.toLowerCase();
    return s != 'delivered' && s != 'cancelled';
  }

  /// Total count of individual units in this order
  int get totalItemUnits =>
      items.fold(0, (acc, item) => acc + item.quantity);

  /// Display status label with title casing
  String get displayStatus {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  OrderModel copyWith({
    int? id,
    int? userId,
    String? status,
    double? subtotal,
    double? discountAmount,
    String? couponCode,
    double? shippingFee,
    double? total,
    String? paymentMethod,
    String? paymentStatus,
    String? shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      couponCode: couponCode ?? this.couponCode,
      shippingFee: shippingFee ?? this.shippingFee,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final parsedItems = <OrderItemModel>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(OrderItemModel.fromJson(item));
        }
      }
    }

    return OrderModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse('${json['user_id']}') ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      subtotal: _toDouble(json['subtotal']),
      discountAmount: _toDouble(json['discount_amount']),
      couponCode: json['coupon_code']?.toString(),
      shippingFee: _toDouble(json['shipping_fee']),
      total: _toDouble(json['total']),
      paymentMethod: (json['payment_method'] ?? 'Cash on Delivery').toString(),
      paymentStatus: (json['payment_status'] ?? 'unpaid').toString(),
      shippingAddress: (json['shipping_address'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      if (couponCode != null) 'coupon_code': couponCode,
      'shipping_fee': shippingFee,
      'total': total,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'shipping_address': shippingAddress,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
