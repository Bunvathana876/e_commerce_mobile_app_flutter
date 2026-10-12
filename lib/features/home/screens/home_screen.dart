import 'package:e_commerc_mobile_app/shared/widgets/bouncing_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../products/widgets/product_card.dart';
import '../../../core/utils/page_transitions.dart';
import '../../products/screens/product_detail_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/category_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final user = authProvider.currentUser;
    final products = productProvider.filteredProducts;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Top Header & Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.fullName ?? "Shopper"} 👋',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'What are you looking for today?',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        // Notification Bell Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 22,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Search Input Box
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                      child: TextField(
                        onChanged: productProvider.setSearchQuery,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search products, brands, gear...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.all(8),
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Promotional Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LIMITED OFFER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Up to 30% Off\nElectronics & Shoes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 54,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),

            // 3. Image-Based Categories Bar
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Swipe for more',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Horizontal Category Carousel
                  SizedBox(
                    height:
                        106, // Increased from 96 to prevent vertical RenderFlex overflow
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      itemCount: categoryProvider.allCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final CategoryModel category =
                            categoryProvider.allCategories[index];
                        final isSelected =
                            productProvider.selectedCategoryId == category.id;

                        return BouncingButton(
                          onTap: () {
                            categoryProvider.selectCategory(category.id);
                            productProvider.selectCategory(category.id);
                          },
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
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white,
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
                                            ? const Color(
                                                0xFF1E88E5,
                                              ).withValues(alpha: 0.28)
                                            : Colors.black.withValues(
                                                alpha: isDark ? 0.2 : 0.04,
                                              ),
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
                                            loadingBuilder:
                                                (context, child, progress) {
                                                  if (progress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    color: isDark
                                                        ? const Color(0xFF0F172A)
                                                        : const Color(0xFFF1F5F9),
                                                    child: const Center(
                                                      child: SizedBox(
                                                        width: 14,
                                                        height: 14,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                            errorBuilder: (_, _, _) =>
                                                Container(
                                                  color: isDark
                                                      ? const Color(0xFF1E293B)
                                                      : const Color(0xFFE2E8F0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    category.icon,
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            color: isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFE2E8F0),
                                            alignment: Alignment.center,
                                            child: Text(
                                              category.icon,
                                              style: const TextStyle(
                                                fontSize: 22,
                                              ),
                                            ),
                                          ),
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
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
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
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 4. Products Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Items',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${products.length} found',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. 2-Column Product Grid
            if (products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No products found matching your search.',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = products[index];
                    return ProductCard(
                      product: item,
                      onTap: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: ProductDetailScreen(product: item),
                          ),
                        );
                      },
                      onToggleFavorite: () =>
                          productProvider.toggleFavorite(item.id),
                      onAddToCart: () {
                        context.read<CartProvider>().addItem(item, quantity: 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${item.name} to cart!'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  }, childCount: products.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
