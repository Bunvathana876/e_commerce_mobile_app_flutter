import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../../../../shared/widgets/bouncing_button.dart';
import '../../cart/providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedVariantIndex = 0;
  final List<String> _variants = const [
    'Standard',
    'Silver Edition',
    'Pro Bundle',
  ];

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productProvider = context.watch<ProductProvider>();

    // Fetch the updated favorite state from the provider
    final currentProduct = productProvider.filteredProducts.firstWhere(
      (item) => item.id == widget.product.id,
      orElse: () => widget.product,
    );

    final totalPrice = currentProduct.price * _quantity;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Banner
                Stack(
                  children: [
                    Container(
                      height: 380,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      ),
                      child: Hero(
                        tag: 'product-image-${currentProduct.id}',
                        child: Image.network(
                          currentProduct.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Top Floating Navigation Header
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            BouncingButton(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.3 : 0.1,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ),

                            // Favorite Toggle Button
                            BouncingButton(
                              onTap: () => productProvider.toggleFavorite(
                                currentProduct.id,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.3 : 0.1,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  currentProduct.isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 20,
                                  color: currentProduct.isFavorite
                                      ? const Color(0xFFEF4444)
                                      : (isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Product Information Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Ratings Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentProduct.discountPercent > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                ),
                              ),
                              child: Text(
                                '${currentProduct.discountPercent}% DISCOUNT',
                                style: const TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),

                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 20,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${currentProduct.rating}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${currentProduct.reviewCount} reviews)',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Product Title
                      Text(
                        currentProduct.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price Display
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${currentProduct.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (currentProduct.originalPrice != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              '\$${currentProduct.originalPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9),
                      ),
                      const SizedBox(height: 16),

                      // Variant Selection
                      Text(
                        'Select Variant',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: List.generate(_variants.length, (index) {
                          final isSelected = _selectedVariantIndex == index;
                          return BouncingButton(
                            onTap: () =>
                                setState(() => _selectedVariantIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1E88E5)
                                    : (isDark
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1E88E5)
                                      : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Text(
                                _variants[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.grey.shade300
                                          : const Color(0xFF475569)),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 22),

                      // Description
                      Text(
                        'Product Overview',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentProduct.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Sticky Bottom Bar with Quantity Stepper & Add to Cart
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.3 : 0.08,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Quantity Stepper ([-] QTY [+])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          BouncingButton(
                            onTap: _decrementQuantity,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '$_quantity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          BouncingButton(
                            onTap: _incrementQuantity,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Add to Cart Action Button
                    Expanded(
                      child: BouncingButton(
                        onTap: () {
                          context.read<CartProvider>().addItem(
                            currentProduct,
                            variant: _variants[_selectedVariantIndex],
                            quantity: _quantity,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added $_quantity × ${currentProduct.name} to cart!',
                              ),
                              backgroundColor: const Color(0xFF1E88E5),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          // ...
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E88E5),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1E88E5,
                                ).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add • \$${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
