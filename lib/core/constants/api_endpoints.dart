import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

// Central configuration for API endpoints and network settings
class ApiEndpoints {
  // Prevent instantiation
  ApiEndpoints._();

  // Active base URL for network requests
  static String _customBaseUrl = '';

  // Get current base URL according to platform or custom setting
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    try {
      if (Platform.isAndroid) {
        // Standard Android emulator loopback alias to host machine
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {
      // In case Platform check is unavailable
    }

    // Default for iOS simulator, macOS, and desktop
    return 'http://localhost:8000';
  }

  // Override base URL at runtime (e.g. for real device testing with local Wi-Fi IP)
  static void setBaseUrl(String url) {
    _customBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Reset base URL to platform defaults
  static void resetBaseUrl() {
    _customBaseUrl = '';
  }

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Authentication endpoints
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String logout = '/api/v1/auth/logout';
  static const String me = '/api/v1/auth/me';
  static const String refreshToken = '/api/v1/auth/refresh';

  // Products endpoints
  static const String products = '/api/v1/products';
  static const String featuredProducts = '/api/v1/products/featured';
  static const String searchProducts = '/api/v1/products/search';
  static String productDetail(int id) => '/api/v1/products/$id';

  // Categories endpoints
  static const String categories = '/api/v1/categories';
  static String categoryProducts(int id) => '/api/v1/categories/$id/products';

  // Cart & Checkout endpoints
  static const String cart = '/api/v1/cart';
  static String cartItem(int productId) => '/api/v1/cart/$productId';
  static const String checkout = '/api/v1/cart/checkout';

  // Orders endpoints
  static const String orders = '/api/v1/orders';
  static String orderDetail(int id) => '/api/v1/orders/$id';
}

