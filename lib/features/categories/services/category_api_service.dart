import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../products/models/product_model.dart';
import '../models/category_model.dart';

// Category service connecting to REST endpoints
class CategoryApiService {
  final ApiClient _client;

  CategoryApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // Fetch list of all categories
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get<List<CategoryModel>>(
      ApiEndpoints.categories,
      parser: (data) => _parseCategoryList(data),
    );

    return response.data ?? [];
  }

  // Fetch products belonging to a specific category
  Future<List<ProductModel>> getCategoryProducts(int categoryId) async {
    final response = await _client.get<List<ProductModel>>(
      ApiEndpoints.categoryProducts(categoryId),
      parser: (data) {
        if (data is List) {
          return data
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    return response.data ?? [];
  }

  // Helper to parse dynamic list or enveloped list from backend
  List<CategoryModel> _parseCategoryList(dynamic data) {
    if (data is List) {
      return data
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['categories'] ?? data['items'] ?? data['data'];
      if (list is List) {
        return list
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }
}

