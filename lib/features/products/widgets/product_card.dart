import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/bouncing_button.dart';
import '../models/product_model.dart';

// Card widget displaying product image, price, rating, and actions in grid views.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;
  final Object? heroTag;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToCart,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BouncingButton(
      onTap: onTap,
      scaleFactor: 0.97,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161F30) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with discount badge and favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(17),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.22,
                    child: Container(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      child: Hero(
                        tag: heroTag ?? 'product-image-${product.id}',
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                cacheWidth: 450,
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
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(isDark),
                              )
                            : _buildImagePlaceholder(isDark),
                      ),
                    ),
                  ),
                ),

                // Discount Badge (Top Left)
                if (product.discountPercent > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),

                // Favorite Heart Button (Top Right)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Semantics(
                    button: true,
                    label: product.isFavorite
                        ? 'Remove from wishlist'
                        : 'Add to wishlist',
                    child: BouncingButton(
                      onTap: onToggleFavorite,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.35 : 0.08,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            product.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey<bool>(product.isFavorite),
                            size: 16,
                            color: product.isFavorite
                                ? const Color(0xFFEF4444)
                                : (isDark
                                    ? Colors.grey.shade400
                                    : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product details: rating, title, price, and add-to-cart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 6, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Upper block: Rating pill + 2-line title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rating Pill with review count
                        if (product.rating > 0)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(
                                          0xFF78350F,
                                        ).withValues(alpha: 0.35)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(
                                            0xFFF59E0B,
                                          ).withValues(alpha: 0.3)
                                        : const Color(0xFFFDE68A),
                                    width: 0.7,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 11,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 2.5),
                                    Text(
                                      product.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFFFCD34D)
                                            : const Color(0xFF92400E),
                                      ),
                                    ),
                                    if (product.reviewCount > 0) ...[
                                      const SizedBox(width: 2),
                                      Text(
                                        '(${product.reviewCount})',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? const Color(
                                                  0xFFFCD34D,
                                                ).withValues(alpha: 0.75)
                                              : const Color(0xFFB45309),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox(height: 14),
                        const SizedBox(height: 3),

                        // Title with 2-line support and neat line height
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.22,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),

                    // Lower block: Price and Add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E88E5),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (product.originalPrice != null &&
                                  product.originalPrice! > product.price)
                                Text(
                                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : const Color(0xFF94A3B8),
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),

                        Semantics(
                          button: true,
                          label: 'Add ${product.name} to cart',
                          child: BouncingButton(
                            onTap: onAddToCart,
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E88E5),
                                    Color(0xFF1565C0),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1E88E5,
                                    ).withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
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
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        child: Icon(
          Icons.shopping_bag_outlined,
          color: isDark ? Colors.grey.shade500 : const Color(0xFF94A3B8),
          size: 22,
        ),
      ),
    );
  }
}
