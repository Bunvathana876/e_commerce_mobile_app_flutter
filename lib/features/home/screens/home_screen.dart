import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../../shared/widgets/promo_banner_carousel.dart';
import '../../cart/providers/cart_provider.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../categories/screens/categories_screen.dart';
import '../../products/models/product_model.dart';
import '../../products/providers/product_provider.dart';
import '../../products/screens/product_detail_screen.dart';
import '../../products/widgets/product_card.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Lazy load below the fold when user scrolls vertically within 250px of the bottom
            if (scrollInfo.metrics.axis == Axis.vertical &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 250) {
              if (productProvider.hasMore && !productProvider.isLoadingMore) {
                productProvider.loadMore();
              }
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              // Search and notification bar
              _HomeSearchBarHeader(
                isDark: isDark,
                onSearchChanged: productProvider.setSearchQuery,
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
              ),

              // 2-column product grid
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
    );
  }
}

// Search bar and notification button header
class _HomeSearchBarHeader extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNotificationTap;

  const _HomeSearchBarHeader({
    required this.isDark,
    required this.onSearchChanged,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          children: [
            // Brand header with logo, title and notification bell
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
                          'Blue Panda',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Explore trending gear',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                BouncingButton(
                  onTap: onNotificationTap,
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.02,
                          ),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
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
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchChanged,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search products, brands, gear...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
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
        titlePrefix: 'Get ',
        highlightText: '40% off',
        titleSuffix: ' your\nfirst order',
        subtitle: '+ \$0 delivery fee on orders \$15+',
        couponCode: 'FIRST40',
        buttonText: 'Order now',
        accentColor: const Color(0xFF059669),
        tag: 'SPECIAL OFFER',
        tagIcon: Icons.local_fire_department_rounded,
        badgeText: 'DEAL',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
        onTap: () => onCategorySelected(0),
      ),
      PromoItem(
        titlePrefix: 'Up to ',
        highlightText: '50% off',
        titleSuffix: ' all\nelectronics',
        subtitle: 'Top laptops, 4K displays & sound gear',
        couponCode: 'TECH50',
        buttonText: 'Shop now',
        accentColor: const Color(0xFF2563EB),
        tag: 'TECH MEGA SALE',
        tagIcon: Icons.bolt_rounded,
        badgeText: 'HOT',
        imageUrl:
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&q=80',
        onTap: () => onCategorySelected(1),
      ),
      PromoItem(
        titlePrefix: 'Flat ',
        highlightText: '30% off',
        titleSuffix: ' trending\nsneakers',
        subtitle: 'Exclusive kicks & new sport drops',
        couponCode: 'KICKS30',
        buttonText: 'Explore',
        accentColor: const Color(0xFFEA580C),
        tag: 'STREETWEAR DROP',
        tagIcon: Icons.trending_up_rounded,
        badgeText: 'NEW',
        imageUrl:
            'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=500&q=80',
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
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E88E5)
                      : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                  width: isSelected ? 2.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF1E88E5).withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: isSelected ? 8 : 4,
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
                          return Container(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9),
                            child: const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
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
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1E88E5)
                    : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
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

  const _HomeSectionHeader({
    required this.isDark,
    required this.title,
    required this.subtitle,
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
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
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

  const _HomeProductGrid({
    required this.isDark,
    required this.products,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No products found matching your search.',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = products[index];
            return ProductCard(
              product: item,
              onTap: () {
                Navigator.of(context).push(
                  SmoothPageRoute(page: ProductDetailScreen(product: item)),
                );
              },
              onToggleFavorite: () => onToggleFavorite(item.id),
              onAddToCart: () => onAddToCart(item),
            );
          },
          childCount: products.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
      ),
    );
  }
}
