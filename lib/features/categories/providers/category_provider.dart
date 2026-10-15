import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryApiService _categoryApiService;
  bool _isLoading = false;
  bool _isBackendConnected = false;

  bool get isLoading => _isLoading;
  bool get isBackendConnected => _isBackendConnected;

  CategoryProvider({CategoryApiService? categoryApiService})
      : _categoryApiService = categoryApiService ?? CategoryApiService() {
    loadFromBackend();
  }

  int _selectedCategoryId = 0;
  String _searchQuery = '';

  int get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<CategoryModel> _categories = [
    const CategoryModel(
      id: 0,
      name: 'All Items',
      icon: '🔥',
      itemCount: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=600&q=80',
    ),

    CategoryModel(
      id: 1,
      name: 'Electronics',
      icon: '💻',
      itemCount: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
    ),
    CategoryModel(
      id: 2,
      name: 'Fashion & Clothing',
      icon: '👕',
      itemCount: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=600&q=80',
    ),
    CategoryModel(
      id: 3,
      name: 'Sneakers & Shoes',
      icon: '👟',
      itemCount: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
    ),
    CategoryModel(
      id: 4,
      name: 'Gaming & Gear',
      icon: '🎮',
      itemCount: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1612287232247-c037ce633464?w=600&q=80',
    ),
    CategoryModel(
      id: 5,
      name: 'Smart Watches',
      icon: '⌚',
      itemCount: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80',
    ),
    CategoryModel(
      id: 6,
      name: 'Audio & Sound',
      icon: '🎧',
      itemCount: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&q=80',
    ),
    CategoryModel(
      id: 7,
      name: 'Bags & Backpacks',
      icon: '🎒',
      itemCount: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600&q=80',
    ),
  ];

  List<CategoryModel> get allCategories => _categories;

  // Filter categories by search query
  List<CategoryModel> get displayCategories {
    return _categories.where((cat) {
      final matchesSearch = cat.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return cat.id != 0 && matchesSearch;
    }).toList();
  }

  // Change selected category
  void selectCategory(int id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  // Update category search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Fetch categories from backend API with local fallback
  Future<void> loadFromBackend() async {
    _isLoading = true;
    try {
      final remoteCategories = await _categoryApiService.getCategories();
      if (remoteCategories.isNotEmpty) {
        final hasAll = remoteCategories.any((c) => c.id == 0);
        _categories = [
          if (!hasAll)
            const CategoryModel(
              id: 0,
              name: 'All Items',
              icon: '🔥',
              itemCount: 25,
            ),
          ...remoteCategories,
        ];
        _isBackendConnected = true;
      }
    } catch (e) {
      debugPrint('CategoryProvider fallback to local categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
