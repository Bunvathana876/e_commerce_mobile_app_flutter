import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:e_commerc_mobile_app/core/constants/api_endpoints.dart';
import 'package:e_commerc_mobile_app/core/network/api_client.dart';
import 'package:e_commerc_mobile_app/core/network/api_exceptions.dart';
import 'package:e_commerc_mobile_app/core/network/api_response.dart';
import 'package:e_commerc_mobile_app/features/products/models/product_model.dart';
import 'package:e_commerc_mobile_app/features/products/services/product_api_service.dart';

void main() {
  group('ApiEndpoints Tests', () {
    tearDown(() {
      ApiEndpoints.resetBaseUrl();
    });

    test('Default baseUrl is available and non-empty', () {
      expect(ApiEndpoints.baseUrl, isNotEmpty);
      expect(ApiEndpoints.baseUrl.startsWith('http'), isTrue);
    });

    test('Custom baseUrl overrides default', () {
      ApiEndpoints.setBaseUrl('https://api.my-ecommerce.com');
      expect(ApiEndpoints.baseUrl, 'https://api.my-ecommerce.com');

      // Removes trailing slash
      ApiEndpoints.setBaseUrl('https://api.my-ecommerce.com/');
      expect(ApiEndpoints.baseUrl, 'https://api.my-ecommerce.com');

      ApiEndpoints.resetBaseUrl();
      expect(ApiEndpoints.baseUrl, isNot('https://api.my-ecommerce.com'));
    });

    test('Dynamic route builders format URLs properly', () {
      expect(ApiEndpoints.productDetail(42), '/api/v1/products/42');
      expect(ApiEndpoints.categoryProducts(5), '/api/v1/categories/5/products');
      expect(ApiEndpoints.cartItem(12), '/api/v1/cart/12');
      expect(ApiEndpoints.orderDetail(99), '/api/v1/orders/99');
    });
  });

  group('ApiException Tests', () {
    test('Extracts simple detail from FastAPI JSON error', () {
      const jsonStr = '{"detail": "Incorrect password"}';
      final msg = ApiException.extractErrorMessage(jsonStr);
      expect(msg, 'Incorrect password');
    });

    test('Extracts validation array error from FastAPI', () {
      const jsonStr = '{"detail": [{"loc": ["body", "email"], "msg": "value is not a valid email"}]}';
      final msg = ApiException.extractErrorMessage(jsonStr);
      expect(msg, 'value is not a valid email');
    });

    test('Falls back when body is not JSON', () {
      const plainStr = '502 Bad Gateway';
      final msg = ApiException.extractErrorMessage(plainStr);
      expect(msg, 'An unexpected error occurred');
    });

    test('Maps HTTP status codes to typed exceptions', () {
      expect(
        ApiException.fromStatusCode(400, '{"detail": "Bad"}'),
        isA<BadRequestException>(),
      );
      expect(
        ApiException.fromStatusCode(401, '{"detail": "Unauthorized"}'),
        isA<UnauthorizedException>(),
      );
      expect(
        ApiException.fromStatusCode(403, '{"detail": "Forbidden"}'),
        isA<ForbiddenException>(),
      );
      expect(
        ApiException.fromStatusCode(404, '{"detail": "Not found"}'),
        isA<NotFoundException>(),
      );
      expect(
        ApiException.fromStatusCode(409, '{"detail": "Conflict"}'),
        isA<ConflictException>(),
      );
      expect(
        ApiException.fromStatusCode(500, '{"detail": "Server error"}'),
        isA<ServerException>(),
      );
    });
  });

  group('ApiResponse Tests', () {
    test('ApiResponse.success stores payload', () {
      final response = ApiResponse<String>.success('hello');
      expect(response.success, isTrue);
      expect(response.data, 'hello');
      expect(response.statusCode, 200);
    });

    test('ApiResponse.failure stores error details', () {
      final response = ApiResponse<int>.failure('Failed', statusCode: 400);
      expect(response.success, isFalse);
      expect(response.message, 'Failed');
      expect(response.statusCode, 400);
    });
  });

  group('ApiClient Tests', () {
    test('Successful GET parses data and injects headers', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Accept'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer test_token');

        final data = [
          {
            'id': 1,
            'name': 'Wireless Headphones',
            'description': 'Noise cancelling',
            'price': 99.99,
            'rating': 4.8,
            'review_count': 120,
            'category_id': 1,
            'image_url': 'https://example.com/headphones.png',
          }
        ];

        return http.Response(jsonEncode(data), 200);
      });

      final apiClient = ApiClient(client: mockClient);
      apiClient.setAuthToken('test_token');

      final response = await apiClient.get<List<ProductModel>>(
        '/test-products',
        parser: (data) => (data as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      expect(response.success, isTrue);
      expect(response.data?.length, 1);
      expect(response.data?.first.name, 'Wireless Headphones');
      expect(response.data?.first.price, 99.99);
    });

    test('Non-200 response throws typed ApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Token expired'}),
          401,
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get<dynamic>('/protected'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('ProductApiService integrates seamlessly with ApiClient', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/api/v1/products'));
        expect(request.url.queryParameters['category_id'], '2');

        final products = [
          {
            'id': 10,
            'name': 'Smart Watch',
            'description': 'Fitness tracking',
            'price': 149.50,
            'rating': 4.5,
            'review_count': 85,
            'category_id': 2,
            'image_url': '',
          }
        ];

        return http.Response(jsonEncode(products), 200);
      });

      final apiClient = ApiClient(client: mockClient);
      final productService = ProductApiService(client: apiClient);

      final result = await productService.getProducts(categoryId: 2);
      expect(result.length, 1);
      expect(result.first.name, 'Smart Watch');
      expect(result.first.price, 149.50);
    });
  });
}

