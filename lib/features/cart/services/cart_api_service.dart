import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/cart_item_model.dart';

// Cart service connecting to REST endpoints
class CartApiService {
  final ApiClient _client;

  CartApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // Fetch current user cart items
  Future<List<CartItemModel>> getCart() async {
    final response = await _client.get<List<CartItemModel>>(
      ApiEndpoints.cart,
      parser: (data) => _parseCartItems(data),
    );

    return response.data ?? [];
  }

  // Add product to remote cart
  Future<CartItemModel> addToCart({
    required int productId,
    int quantity = 1,
    String variant = 'Standard',
  }) async {
    final response = await _client.post<CartItemModel>(
      ApiEndpoints.cart,
      body: {
        'product_id': productId,
        'quantity': quantity,
        'variant': variant,
      },
      parser: (data) => CartItemModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.data == null) {
      throw Exception('Failed to add item to cart');
    }

    return response.data!;
  }

  // Update item quantity in cart
  Future<void> updateQuantity({
    required int productId,
    required int quantity,
  }) async {
    await _client.put<dynamic>(
      ApiEndpoints.cartItem(productId),
      body: {'quantity': quantity},
    );
  }

  // Remove product from cart
  Future<void> removeFromCart(int productId) async {
    await _client.delete<dynamic>(ApiEndpoints.cartItem(productId));
  }

  // Submit cart checkout
  Future<Map<String, dynamic>> checkout(Map<String, dynamic> checkoutData) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.checkout,
      body: checkoutData,
      parser: (data) => data as Map<String, dynamic>,
    );

    return response.data ?? {};
  }

  // Parse cart items list from dynamic response
  List<CartItemModel> _parseCartItems(dynamic data) {
    if (data is List) {
      return data
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] ?? data['cart_items'] ?? data['data'];
      if (items is List) {
        return items
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }
}

