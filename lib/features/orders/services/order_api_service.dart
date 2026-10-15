import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/order_model.dart';

/// REST API service for Orders, connecting to FastAPI backend
class OrderApiService {
  final ApiClient _client;

  OrderApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Fetch all orders placed by the current authenticated user
  Future<List<OrderModel>> getOrders() async {
    final response = await _client.get<List<OrderModel>>(
      ApiEndpoints.orders,
      parser: (data) => _parseOrderList(data),
    );

    return response.data ?? [];
  }

  /// Fetch a single order's complete details by ID
  Future<OrderModel?> getOrderById(int orderId) async {
    final response = await _client.get<OrderModel?>(
      ApiEndpoints.orderDetail(orderId),
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final orderData = data['data'] ?? data;
          if (orderData is Map<String, dynamic>) {
            return OrderModel.fromJson(orderData);
          }
        }
        return null;
      },
    );

    return response.data;
  }

  /// Place a new order via the backend API
  Future<OrderModel?> createOrder({
    required String shippingAddress,
    required String paymentMethod,
    String? phone,
    String? fullName,
    String? couponCode,
  }) async {
    final response = await _client.post<OrderModel?>(
      ApiEndpoints.orders,
      body: {
        'shipping_address': shippingAddress,
        'payment_method': paymentMethod,
        'phone': ?phone,
        'full_name': ?fullName,
        'coupon_code': ?couponCode,
      },
      parser: (data) {
        if (data is Map<String, dynamic>) {
          final orderData = data['data'] ?? data;
          if (orderData is Map<String, dynamic>) {
            return OrderModel.fromJson(orderData);
          }
        }
        return null;
      },
    );

    return response.data;
  }

  /// Parses order list from backend enveloped or raw list format
  List<OrderModel> _parseOrderList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => OrderModel.fromJson(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['orders'] ?? data['data'] ?? data['items'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((item) => OrderModel.fromJson(item))
            .toList();
      }
    }
    return [];
  }
}
