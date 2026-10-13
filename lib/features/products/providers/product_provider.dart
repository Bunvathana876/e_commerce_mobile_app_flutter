import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

// Manages catalog products, categories, search filtering, and favorites.
class ProductProvider extends ChangeNotifier {
  // Filter state
  int _selectedCategoryId = 0; // 0 represents all items
  String _searchQuery = '';

  int get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  // Category definitions
  final List<CategoryModel> _categories = const [
    CategoryModel(id: 0, name: 'All Items', icon: '🔥'),
    CategoryModel(id: 1, name: 'Electronics', icon: '💻'),
    CategoryModel(id: 2, name: 'Fashion & Clothing', icon: '👕'),
    CategoryModel(id: 3, name: 'Sneakers & Shoes', icon: '👟'),
    CategoryModel(id: 4, name: 'Gaming & Gear', icon: '🎮'),
    CategoryModel(id: 5, name: 'Smart Watches', icon: '⌚'),
    CategoryModel(id: 6, name: 'Audio & Sound', icon: '🎧'),
    CategoryModel(id: 7, name: 'Bags & Backpacks', icon: '🎒'),
  ];

  // Favorites
  List<ProductModel> get favoriteProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  int get totalFavoritesCount => favoriteProducts.length;

  void clearAllFavorites() {
    _products = _products
        .map((item) => item.copyWith(isFavorite: false))
        .toList();
    notifyListeners();
  }

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get allProducts => List.unmodifiable(_products);

  // Sample catalog data
  List<ProductModel> _products = [
    // Electronics
    const ProductModel(
      id: 101,
      name: 'UltraBook Pro 15" M2 Laptop',
      description:
          'Ultra-thin lightweight aluminum laptop with retina display and all-day battery life.',
      price: 1199.00,
      originalPrice: 1399.00,
      discountPercent: 14,
      rating: 4.9,
      reviewCount: 312,
      categoryId: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&q=80',
    ),
    const ProductModel(
      id: 102,
      name: 'Portable 4K Ultra HD Monitor',
      description:
          'Slim 15.6-inch IPS external USB-C gaming and productivity display.',
      price: 189.00,
      originalPrice: 229.00,
      discountPercent: 17,
      rating: 4.7,
      reviewCount: 142,
      categoryId: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500&q=80',
    ),
    const ProductModel(
      id: 103,
      name: 'Wireless 3-in-1 Fast Charging Station',
      description:
          'Mag-safe compatible fast wireless charging dock for phone, watch, and earbuds.',
      price: 45.00,
      originalPrice: 59.99,
      discountPercent: 25,
      rating: 4.6,
      reviewCount: 88,
      categoryId: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1622445262464-84b1456045b6?w=500&q=80',
    ),
    const ProductModel(
      id: 104,
      name: 'Aluminum 7-in-1 USB-C Hub Adapter',
      description:
          'High-speed 4K HDMI, 100W PD charging port, and ultra-fast card readers.',
      price: 29.50,
      originalPrice: 39.00,
      discountPercent: 24,
      rating: 4.8,
      reviewCount: 195,
      categoryId: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1544652478-6653e09f18a2?w=500&q=80',
    ),

    // Fashion & Clothing
    const ProductModel(
      id: 2,
      name: 'Minimalist Cotton Casual Hoodie',
      description:
          'Soft organic heavyweight cotton streetwear hoodie in light grey.',
      price: 49.00,
      originalPrice: 65.00,
      discountPercent: 25,
      rating: 4.6,
      reviewCount: 118,
      categoryId: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=500&q=80',
    ),
    const ProductModel(
      id: 201,
      name: 'Vintage Washed Denim Jacket',
      description:
          'Classic rugged button-up denim jacket with relaxed dropped shoulders.',
      price: 79.00,
      originalPrice: 99.00,
      discountPercent: 20,
      rating: 4.7,
      reviewCount: 84,
      categoryId: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=500&q=80',
    ),
    const ProductModel(
      id: 202,
      name: 'Premium Heavyweight Crewneck Tee',
      description:
          'Breathable 100% combed cotton everyday lifestyle basic t-shirt.',
      price: 28.00,
      originalPrice: 35.00,
      discountPercent: 20,
      rating: 4.5,
      reviewCount: 156,
      categoryId: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&q=80',
    ),
    const ProductModel(
      id: 203,
      name: 'Tailored Everyday Slim Chino Trousers',
      description:
          'Stretch cotton comfortable modern fit pants for work or weekend leisure.',
      price: 54.00,
      originalPrice: 68.00,
      discountPercent: 21,
      rating: 4.6,
      reviewCount: 92,
      categoryId: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=500&q=80',
    ),

    // Sneakers & Shoes
    const ProductModel(
      id: 3,
      name: 'Running Air Pro Cushion Sneakers',
      description: 'Breathable lightweight performance mesh running shoes.',
      price: 89.50,
      originalPrice: 110.00,
      discountPercent: 18,
      rating: 4.9,
      reviewCount: 412,
      categoryId: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80',
    ),
    const ProductModel(
      id: 301,
      name: 'Urban High-Top Skater Sneakers',
      description:
          'Durable vulcanized canvas high-tops with cushioned shock-absorbing insole.',
      price: 65.00,
      originalPrice: 80.00,
      discountPercent: 19,
      rating: 4.7,
      reviewCount: 173,
      categoryId: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=500&q=80',
    ),
    const ProductModel(
      id: 302,
      name: 'Retro Leather Court Trainers',
      description:
          'Timeless white leather heritage tennis sneakers with gum outsole.',
      price: 92.00,
      originalPrice: 115.00,
      discountPercent: 20,
      rating: 4.8,
      reviewCount: 220,
      categoryId: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=500&q=80',
    ),
    const ProductModel(
      id: 303,
      name: 'All-Terrain Trail Running Trainers',
      description:
          'Rugged grip waterproof hiking and cross-country trainers with high traction.',
      price: 108.00,
      originalPrice: 135.00,
      discountPercent: 20,
      rating: 4.8,
      reviewCount: 88,
      categoryId: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=500&q=80',
    ),

    // Gaming & Gear
    const ProductModel(
      id: 5,
      name: 'Classic Mechanical Retro Gaming Mouse',
      description: 'Ergonomic gaming mouse with programmable RGB lighting.',
      price: 39.99,
      originalPrice: 49.99,
      discountPercent: 20,
      rating: 4.5,
      reviewCount: 95,
      categoryId: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=500&q=80',
    ),
    const ProductModel(
      id: 401,
      name: 'RGB Hot-Swap Mechanical Keyboard',
      description:
          'Compact 75% mechanical keyboard with customizable tactile red switches.',
      price: 119.00,
      originalPrice: 149.00,
      discountPercent: 20,
      rating: 4.9,
      reviewCount: 280,
      categoryId: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500&q=80',
    ),
    const ProductModel(
      id: 402,
      name: 'Wireless Esports Gamepad Controller',
      description:
          'Low latency Bluetooth / 2.4G wireless controller with dual haptic rumble.',
      price: 64.00,
      originalPrice: 79.99,
      discountPercent: 20,
      rating: 4.7,
      reviewCount: 164,
      categoryId: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1600080972464-8e5f35f63d08?w=500&q=80',
    ),
    const ProductModel(
      id: 403,
      name: 'Surround Sound Esports Gaming Headset',
      description:
          '7.1 immersive surround sound headset with noise-canceling flip mic.',
      price: 85.00,
      originalPrice: 105.00,
      discountPercent: 19,
      rating: 4.6,
      reviewCount: 130,
      categoryId: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1599669454699-248893623440?w=500&q=80',
    ),

    // Smart Watches
    const ProductModel(
      id: 4,
      name: 'Smart OLED 4K Fitness Watch',
      description:
          'Waterproof smartwatch with continuous heart rate and GPS tracking.',
      price: 199.00,
      originalPrice: 249.00,
      discountPercent: 20,
      rating: 4.7,
      reviewCount: 330,
      categoryId: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80',
    ),
    const ProductModel(
      id: 501,
      name: 'Titanium Rugged Outdoor Smartwatch',
      description:
          'Military grade shock-resistant smartwatch with 14-day extended battery life.',
      price: 269.00,
      originalPrice: 320.00,
      discountPercent: 16,
      rating: 4.9,
      reviewCount: 145,
      categoryId: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=500&q=80',
    ),
    const ProductModel(
      id: 502,
      name: 'Minimalist Slim Health Band Watch',
      description:
          'Featherlight sleep and fitness activity tracker with AMOLED curved glass.',
      price: 129.00,
      originalPrice: 159.00,
      discountPercent: 19,
      rating: 4.6,
      reviewCount: 98,
      categoryId: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1510017803434-a899398421b3?w=500&q=80',
    ),

    // Audio & Sound
    const ProductModel(
      id: 1,
      name: 'Wireless Noise-Canceling Headphones',
      description:
          'Premium active noise-canceling over-ear bluetooth headphones.',
      price: 129.99,
      originalPrice: 169.99,
      discountPercent: 23,
      rating: 4.8,
      reviewCount: 245,
      categoryId: 6,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80',
    ),
    const ProductModel(
      id: 601,
      name: 'Studio Pro Wireless In-Ear Earbuds',
      description:
          'True wireless spatial audio earbuds with active transparency mode.',
      price: 89.00,
      originalPrice: 119.00,
      discountPercent: 25,
      rating: 4.8,
      reviewCount: 210,
      categoryId: 6,
      imageUrl:
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500&q=80',
    ),
    const ProductModel(
      id: 602,
      name: 'Rugged Waterproof Bluetooth Speaker',
      description:
          '360-degree deep bass portable outdoor speaker with 20-hour playback.',
      price: 59.00,
      originalPrice: 75.00,
      discountPercent: 21,
      rating: 4.7,
      reviewCount: 167,
      categoryId: 6,
      imageUrl:
          'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=500&q=80',
    ),

    // Bags & Backpacks
    const ProductModel(
      id: 6,
      name: 'Designer Casual Canvas Tote Bag',
      description:
          'Spacious everyday cotton tote with reinforced shoulder straps.',
      price: 24.50,
      originalPrice: 32.00,
      discountPercent: 23,
      rating: 4.4,
      reviewCount: 67,
      categoryId: 7,
      imageUrl:
          'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&q=80',
    ),
    const ProductModel(
      id: 701,
      name: 'Waterproof Urban Commuter Backpack',
      description:
          'Ergonomic 25L laptop bag with hidden security pockets and luggage strap.',
      price: 85.00,
      originalPrice: 110.00,
      discountPercent: 23,
      rating: 4.8,
      reviewCount: 194,
      categoryId: 7,
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&q=80',
    ),
    const ProductModel(
      id: 702,
      name: 'Compact Crossbody Shoulder Sling',
      description:
          'Lightweight weather-resistant day sling for gadgets, wallet, and essentials.',
      price: 38.00,
      originalPrice: 48.00,
      discountPercent: 21,
      rating: 4.6,
      reviewCount: 112,
      categoryId: 7,
      imageUrl:
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=500&q=80',
    ),
  ];

  // Pagination state for lazy loading
  int _displayedCount = 6;
  final int _pageSize = 6;
  bool _isLoadingMore = false;

  int get displayedCount => _displayedCount;
  int get pageSize => _pageSize;
  bool get isLoadingMore => _isLoadingMore;

  // Filter products by selected category and search query
  List<ProductModel> get filteredProducts {
    return _products.where((item) {
      final matchesCategory =
          _selectedCategoryId == 0 || item.categoryId == _selectedCategoryId;
      final matchesQuery =
          _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // Slice of products to display in the grid
  List<ProductModel> get displayedProducts {
    final all = filteredProducts;
    if (all.length <= _displayedCount) {
      return all;
    }
    return all.sublist(0, _displayedCount);
  }

  bool get hasMore => _displayedCount < filteredProducts.length;

  // Load the next page of products
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    // Small delay to simulate network latency for smoother UX
    await Future.delayed(const Duration(milliseconds: 600));

    _displayedCount = (_displayedCount + _pageSize).clamp(
      0,
      filteredProducts.length,
    );
    _isLoadingMore = false;
    notifyListeners();
  }

  // Reset pagination back to first batch
  void resetPagination() {
    _displayedCount = _pageSize;
    _isLoadingMore = false;
    notifyListeners();
  }

  void selectCategory(int categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _displayedCount = _pageSize;
    _isLoadingMore = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _displayedCount = _pageSize;
    _isLoadingMore = false;
    notifyListeners();
  }

  // Toggle wishlist state for a product
  void toggleFavorite(int productId) {
    _products = _products.map((item) {
      if (item.id == productId) {
        return item.copyWith(isFavorite: !item.isFavorite);
      }
      return item;
    }).toList();
    notifyListeners();
  }
}
