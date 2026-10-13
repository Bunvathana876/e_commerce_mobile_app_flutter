import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/product_model.dart';

// Product service connecting to REST endpoints
class ProductApiService {
  final ApiClient _client;

  ProductApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // Fetch list of products with optional category and search filters
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (categoryId != null && categoryId > 0) {
      queryParams['category_id'] = categoryId;
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _client.get<List<ProductModel>>(
      ApiEndpoints.products,
      queryParameters: queryParams,
      parser: (data) => _parseProductList(data),
    );

    return response.data ?? [];
  }

  // Fetch single product detail by ID
  Future<ProductModel> getProductById(int id) async {
    final response = await _client.get<ProductModel>(
      ApiEndpoints.productDetail(id),
      parser: (data) => ProductModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.data == null) {
      throw Exception('Product with id $id not found');
    }

    return response.data!;
  }

  // Fetch featured / promotional products for banners and highlights
  Future<List<ProductModel>> getFeaturedProducts() async {
    final response = await _client.get<List<ProductModel>>(
      ApiEndpoints.featuredProducts,
      parser: (data) => _parseProductList(data),
    );

    return response.data ?? [];
  }

  // Search products by keyword
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _client.get<List<ProductModel>>(
      ApiEndpoints.searchProducts,
      queryParameters: {'q': query},
      parser: (data) => _parseProductList(data),
    );

    return response.data ?? [];
  }

  // Helper to parse dynamic list or enveloped list from backend
  List<ProductModel> _parseProductList(dynamic data) {
    if (data is List) {
      return data
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['items'] ?? data['products'] ?? data['data'];
      if (list is List) {
        return list
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }
}

