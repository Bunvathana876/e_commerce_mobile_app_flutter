import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../cart/providers/cart_provider.dart';
// import '../../products/models/category_model.dart';
import '../../products/providers/product_provider.dart';
import '../../products/screens/product_detail_screen.dart';
import '../../products/widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onExplore;

  const FavoritesScreen({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.read<CartProvider>();
    final favorites = productProvider.favoriteProducts;

    // 1. Empty State
    if (favorites.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Wishlist',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_outline_rounded,
                    size: 72,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your wishlist is empty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on any product to save items you want to buy later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                if (onExplore != null)
                  BouncingButton(
                    onTap: onExplore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1E88E5,
                            ).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Explore Products',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
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
        ),
      );
    }

    // 2. Populated Favorites Grid
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Wishlist (${favorites.length})',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Wishlist',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF64748B),
            ),
            onPressed: () => _confirmClearDialog(context, productProvider),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = favorites[index];
                return ProductCard(
                  product: item,
                  onTap: () {
                    Navigator.of(context).push(
                      SmoothPageRoute(page: ProductDetailScreen(product: item)),
                    );
                  },
                  onToggleFavorite: () {
                    productProvider.toggleFavorite(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed ${item.name} from wishlist'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onAddToCart: () {
                    cartProvider.addItem(item, quantity: 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${item.name} to cart!'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }, childCount: favorites.length),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearDialog(BuildContext context, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text(
          'Are you sure you want to remove all saved items from your wishlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllFavorites();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Remove All',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
