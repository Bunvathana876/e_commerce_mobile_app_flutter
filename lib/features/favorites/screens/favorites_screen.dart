import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../cart/providers/cart_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../products/screens/product_detail_screen.dart';
import '../../products/widgets/product_grid.dart';

// Displays the user's saved items or an empty state when none are added.
class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onExplore;

  const FavoritesScreen({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.read<CartProvider>();
    final favorites = productProvider.favoriteProducts;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Empty state when wishlist has no items
    if (favorites.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
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
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.18 : 0.08),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF87171),
                            Color(0xFFEF4444),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your wishlist is empty',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on any product to save items you want to buy later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                if (onExplore != null)
                  BouncingButton(
                    onTap: onExplore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E88E5),
                            Color(0xFF1565C0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1E88E5,
                            ).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
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

    // Populated favorites grid view
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Wishlist (${favorites.length})',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Wishlist',
            icon: Icon(
              Icons.delete_outline_rounded,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
            ),
            onPressed: () => _confirmClearDialog(context, productProvider),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverProductGrid(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            products: favorites,
            heroTagPrefix: 'fav-product',
            onTap: (item) {
              Navigator.of(context).push(
                SmoothPageRoute(
                  page: ProductDetailScreen(product: item),
                ),
              );
            },
            onToggleFavorite: (id) {
              final item = favorites.firstWhere((p) => p.id == id);
              productProvider.toggleFavorite(id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${item.name} from wishlist'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onAddToCart: (item) {
              cartProvider.addItem(item, quantity: 1);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${item.name} to cart!'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Prompts confirmation before wiping wishlist
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
