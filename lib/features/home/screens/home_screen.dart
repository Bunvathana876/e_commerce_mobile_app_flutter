import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../../shared/widgets/promo_banner_carousel.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../categories/screens/categories_screen.dart';
import '../../products/models/product_model.dart';
import '../../products/providers/product_provider.dart';
import '../../products/screens/product_detail_screen.dart';
import '../../products/widgets/product_grid.dart';

// Home storefront showing search, banners, categories, and products
class HomeScreen extends StatelessWidget {
  final VoidCallback? onSeeAllCategories;

  const HomeScreen({super.key, this.onSeeAllCategories});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final displayedProducts = productProvider.displayedProducts;
    final totalProducts = productProvider.filteredProducts.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedCategory = categoryProvider.allCategories.firstWhere(
      (c) => c.id == productProvider.selectedCategoryId,
      orElse: () => const CategoryModel(
        id: 0,
        name: 'All Items',
        icon: '🔥',
        itemCount: 0,
        imageUrl: '',
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Lazy load below the fold when user scrolls vertically within 350px of the bottom
            if (scrollInfo.metrics.axis == Axis.vertical &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 350) {
              if (productProvider.hasMore && !productProvider.isLoadingMore) {
                productProvider.loadMore();
              }
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                productProvider.loadFromBackend(force: true),
                categoryProvider.loadFromBackend(),
              ]);
            },
            child: CustomScrollView(
              slivers: [
                // Search and notification bar with welcome header
                _HomeSearchBarHeader(
                  isDark: isDark,
                  searchQuery: productProvider.searchQuery,
                  onSearchChanged: productProvider.setSearchQuery,
                  onFilterTap: () =>
                      _showSortFilterModal(context, productProvider, isDark),
                  onNotificationTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications are up to date!'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),

                // Promotional banner carousel
                _HomePromoCarousel(
                  onCategorySelected: (catId) =>
                      productProvider.selectCategory(catId),
                ),

                // Categories row
                _HomeCategoriesBar(
                  isDark: isDark,
                  categories: categoryProvider.allCategories,
                  selectedCategoryId: productProvider.selectedCategoryId,
                  onCategorySelected: (catId) {
                    categoryProvider.selectCategory(catId);
                    productProvider.selectCategory(catId);
                  },
                  onSeeAll: () {
                    if (onSeeAllCategories != null) {
                      onSeeAllCategories!();
                    } else {
                      Navigator.of(context).push(
                        SmoothPageRoute(page: const CategoriesScreen()),
                      );
                    }
                  },
                ),

                // Popular products header
                _HomeSectionHeader(
                  isDark: isDark,
                  title: 'Popular Items',
                  subtitle: totalProducts == displayedProducts.length
                      ? '$totalProducts found'
                      : 'Showing ${displayedProducts.length} of $totalProducts',
                  activeSort: _sortLabel(productProvider.sortBy),
                  onSortTap: () =>
                      _showSortFilterModal(context, productProvider, isDark),
                ),

                // Active filter chip banner if filtering is active
                if (productProvider.selectedCategoryId != 0 ||
                    productProvider.searchQuery.isNotEmpty ||
                    productProvider.sortBy != 'default')
                  SliverToBoxAdapter(
                    child: _HomeActiveFilterBar(
                      isDark: isDark,
                      categoryName: productProvider.selectedCategoryId != 0
                          ? selectedCategory.name
                          : null,
                      searchQuery: productProvider.searchQuery.isNotEmpty
                          ? productProvider.searchQuery
                          : null,
                      sortLabel: productProvider.sortBy != 'default'
                          ? _sortLabel(productProvider.sortBy)
                          : null,
                      onClearCategory: () {
                        categoryProvider.selectCategory(0);
                        productProvider.selectCategory(0);
                      },
                      onClearSearch: () => productProvider.setSearchQuery(''),
                      onClearSort: () => productProvider.setSortBy('default'),
                      onResetAll: () {
                        categoryProvider.selectCategory(0);
                        productProvider.resetFilters();
                      },
                    ),
                  ),

                // Error state or Loading Shimmer or 2-column Product Grid
                if (productProvider.errorMessage != null &&
                    displayedProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: _HomeErrorState(
                      isDark: isDark,
                      message: productProvider.errorMessage!,
                      onRetry: () =>
                          productProvider.loadFromBackend(force: true),
                    ),
                  )
                else if (productProvider.isLoading && displayedProducts.isEmpty)
                  _HomeShimmerGrid(isDark: isDark)
                else
                  _HomeProductGrid(
                    isDark: isDark,
                    products: displayedProducts,
                    onToggleFavorite: productProvider.toggleFavorite,
                    onAddToCart: (product) {
                      context.read<CartProvider>().addItem(product, quantity: 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${product.name} to cart!'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onResetFilters: () {
                      categoryProvider.selectCategory(0);
                      productProvider.resetFilters();
                    },
                  ),

                // Loading spinner when fetching more items
                if (productProvider.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Loading more items...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (!productProvider.hasMore &&
                    displayedProducts.length >= 6)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                      child: Center(
                        child: Text(
                          "You've viewed all $totalProducts products ✓",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _sortLabel(String sortId) {
    switch (sortId) {
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'rating':
        return 'Top Rated';
      default:
        return 'Popular';
    }
  }

  static void _showSortFilterModal(
    BuildContext context,
    ProductProvider provider,
    bool isDark,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161F30) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final sorts = [
          {
            'id': 'default',
            'label': 'Popular & Featured',
            'icon': Icons.local_fire_department_rounded,
          },
          {
            'id': 'price_low',
            'label': 'Price: Low to High',
            'icon': Icons.arrow_upward_rounded,
          },
          {
            'id': 'price_high',
            'label': 'Price: High to Low',
            'icon': Icons.arrow_downward_rounded,
          },
          {
            'id': 'rating',
            'label': 'Customer Rating',
            'icon': Icons.star_rounded,
          },
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    if (provider.sortBy != 'default')
                      GestureDetector(
                        onTap: () {
                          provider.setSortBy('default');
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ...sorts.map((sort) {
                  final isSelected = provider.sortBy == sort['id'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E88E5).withValues(alpha: 0.15)
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        sort['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? const Color(0xFF1E88E5)
                            : (isDark
                                ? Colors.grey.shade400
                                : const Color(0xFF64748B)),
                      ),
                    ),
                    title: Text(
                      sort['label'] as String,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF1E88E5)
                            : (isDark
                                ? Colors.white
                                : const Color(0xFF0F172A)),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF1E88E5),
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      provider.setSortBy(sort['id'] as String);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Search bar and notification button header
class _HomeSearchBarHeader extends StatefulWidget {
  final bool isDark;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNotificationTap;
  final VoidCallback? onFilterTap;

  const _HomeSearchBarHeader({
    required this.isDark,
    required this.onSearchChanged,
    required this.onNotificationTap,
    this.searchQuery = '',
    this.onFilterTap,
  });

  @override
  State<_HomeSearchBarHeader> createState() => _HomeSearchBarHeaderState();
}

class _HomeSearchBarHeaderState extends State<_HomeSearchBarHeader> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _HomeSearchBarHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getGreetingBadge(BuildContext context) {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;
      if (user != null && user.fullName.trim().isNotEmpty) {
        final firstName = user.fullName.trim().split(' ').first;
        return 'Hello, $firstName 👋';
      }
    } catch (_) {}
    return 'Welcome 👋';
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
        child: Column(
          children: [
            // Brand header with logo, title, greeting and notification bell
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const AppLogo(size: 60, borderRadius: 12),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreetingBadge(context),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E88E5),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Text(
                              'Blue Panda',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withValues(
                                  alpha: widget.isDark ? 0.22 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'STORE',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E88E5),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Explore trending gear',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: widget.isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                BouncingButton(
                  onTap: widget.onNotificationTap,
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF161F30)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.isDark
                            ? const Color(0xFF253248)
                            : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: widget.isDark ? 0.25 : 0.04,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 22,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.isDark
                                    ? const Color(0xFF161F30)
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search input box
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF161F30) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark
                      ? const Color(0xFF253248)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: widget.isDark ? 0.25 : 0.04,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: (val) {
                  widget.onSearchChanged(val);
                  setState(() {});
                },
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search products, brands, gear...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: widget.isDark
                        ? Colors.grey.shade500
                        : const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: widget.isDark
                        ? Colors.grey.shade400
                        : const Color(0xFF64748B),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_controller.text.isNotEmpty)
                        GestureDetector(
                          key: const Key('search_clear_button'),
                          onTap: () {
                            _controller.clear();
                            widget.onSearchChanged('');
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: widget.isDark
                                  ? Colors.grey.shade400
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      BouncingButton(
                        onTap: widget.onFilterTap ?? () {},
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E88E5),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1E88E5,
                                ).withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Promotional banners carousel
class _HomePromoCarousel extends StatelessWidget {
  final ValueChanged<int> onCategorySelected;

  const _HomePromoCarousel({required this.onCategorySelected});

  List<PromoItem> _buildBanners() {
    return [
      PromoItem(
        titlePrefix: 'Curated ',
        highlightText: 'Summer ',
        titleSuffix: 'Styles',
        subtitle: 'Explore minimal essentials & fresh apparel',
        buttonText: 'Discover',
        accentColor: const Color(0xFF059669),
        tag: 'NEW COLLECTION',
        tagIcon: Icons.auto_awesome_rounded,
        badgeText: 'FEATURED',
        imageUrl:
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&q=80',
        onTap: () => onCategorySelected(2),
      ),
      PromoItem(
        titlePrefix: 'Next-Gen ',
        highlightText: 'Audio ',
        titleSuffix: '& Tech',
        subtitle: 'Studio headphones, 4K displays & gear',
        buttonText: 'Shop Tech',
        accentColor: const Color(0xFF2563EB),
        tag: 'WORKSPACE EDIT',
        tagIcon: Icons.headphones_rounded,
        badgeText: 'POPULAR',
        imageUrl:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
        onTap: () => onCategorySelected(1),
      ),
      PromoItem(
        titlePrefix: 'The Street ',
        highlightText: 'Sneaker ',
        titleSuffix: 'Drop',
        subtitle: 'Trending silhouettes & limited colorways',
        buttonText: 'Explore Drops',
        accentColor: const Color(0xFFEA580C),
        tag: 'EXCLUSIVE',
        tagIcon: Icons.local_fire_department_rounded,
        badgeText: 'TRENDING',
        imageUrl:
            'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=600&q=80',
        onTap: () => onCategorySelected(3),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: PromoBannerCarousel(
        autoScrollDuration: const Duration(seconds: 4),
        items: _buildBanners(),
      ),
    );
  }
}

// Horizontal categories bar
class _HomeCategoriesBar extends StatelessWidget {
  final bool isDark;
  final List<CategoryModel> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onCategorySelected;
  final VoidCallback onSeeAll;

  const _HomeCategoriesBar({
    required this.isDark,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAll,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFF1E88E5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Categories List
          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategoryId == category.id;

                return _CategoryCircleItem(
                  category: category,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => onCategorySelected(category.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Category circle item
class _CategoryCircleItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCircleItem({
    required this.category,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onTap,
      child: SizedBox(
        width: 66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Category Avatar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 62,
              height: 62,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF161F30) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E88E5)
                      : (isDark
                          ? const Color(0xFF253248)
                          : const Color(0xFFE2E8F0)),
                  width: isSelected ? 2.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF1E88E5).withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: isSelected ? 10 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: category.imageUrl.isNotEmpty
                    ? Image.network(
                        category.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            highlightColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFFFFFFF),
                            child: Container(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => _fallbackIcon(),
                      )
                    : _fallbackIcon(),
              ),
            ),
            const SizedBox(height: 6),

            // Truncated Category Label
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1E88E5)
                    : (isDark
                        ? Colors.grey.shade300
                        : const Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: Text(category.icon, style: const TextStyle(fontSize: 22)),
    );
  }
}

// Section header with title and item count
class _HomeSectionHeader extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final String? activeSort;
  final VoidCallback? onSortTap;

  const _HomeSectionHeader({
    required this.isDark,
    required this.title,
    required this.subtitle,
    this.activeSort,
    this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2563EB).withValues(alpha: 0.5)
                          : const Color(0xFFDBEAFE),
                    ),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
                if (onSortTap != null) ...[
                  const SizedBox(width: 8),
                  BouncingButton(
                    onTap: onSortTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 13,
                            color: isDark
                                ? Colors.grey.shade300
                                : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activeSort ?? 'Sort',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Active filters chips row when filter or search is active
class _HomeActiveFilterBar extends StatelessWidget {
  final bool isDark;
  final String? categoryName;
  final String? searchQuery;
  final String? sortLabel;
  final VoidCallback onClearCategory;
  final VoidCallback onClearSearch;
  final VoidCallback onClearSort;
  final VoidCallback onResetAll;

  const _HomeActiveFilterBar({
    required this.isDark,
    this.categoryName,
    this.searchQuery,
    this.sortLabel,
    required this.onClearCategory,
    required this.onClearSearch,
    required this.onClearSort,
    required this.onResetAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (categoryName != null)
              _buildFilterChip(
                label: 'Category: $categoryName',
                onClear: onClearCategory,
              ),
            if (searchQuery != null)
              _buildFilterChip(
                label: 'Search: "$searchQuery"',
                onClear: onClearSearch,
              ),
            if (sortLabel != null)
              _buildFilterChip(
                label: 'Sort: $sortLabel',
                onClear: onClearSort,
              ),
            GestureDetector(
              onTap: onResetAll,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onClear,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E3A8A).withValues(alpha: 0.25)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2563EB).withValues(alpha: 0.4)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close_rounded,
              size: 13,
              color: Color(0xFF1E88E5),
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer skeleton grid for initial loading state
class _HomeShimmerGrid extends StatelessWidget {
  final bool isDark;

  const _HomeShimmerGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.60,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              highlightColor: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFFFFFFF),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161F30) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF253248)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.22,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(17),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(9, 6, 9, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 80,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 55,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: 6,
        ),
      ),
    );
  }
}

// Error state widget
class _HomeErrorState extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorState({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                    : const Color(0xFFFEE2E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 30,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            BouncingButton(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2-column product grid and empty state
class _HomeProductGrid extends StatelessWidget {
  final bool isDark;
  final List<ProductModel> products;
  final ValueChanged<int> onToggleFavorite;
  final ValueChanged<ProductModel> onAddToCart;
  final VoidCallback? onResetFilters;

  const _HomeProductGrid({
    required this.isDark,
    required this.products,
    required this.onToggleFavorite,
    required this.onAddToCart,
    this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFDBEAFE),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.search_off_rounded,
                    size: 34,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found matching your search.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try checking for spelling errors, using more general terms, or resetting your category filters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.grey.shade400
                        : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                if (onResetFilters != null) ...[
                  const SizedBox(height: 20),
                  BouncingButton(
                    onTap: onResetFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1E88E5,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Reset Filters',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return SliverProductGrid(
      products: products,
      heroTagPrefix: 'home-product',
      onTap: (item) {
        Navigator.of(context).push(
          SmoothPageRoute(page: ProductDetailScreen(product: item)),
        );
      },
      onToggleFavorite: onToggleFavorite,
      onAddToCart: onAddToCart,
    );
  }
}
