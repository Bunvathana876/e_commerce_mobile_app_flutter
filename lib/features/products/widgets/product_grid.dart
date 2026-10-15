import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card.dart';
export 'product_card.dart';

// Reusable responsive product grid for Home, Category Products, and Favorites screens.
class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onTap;
  final ValueChanged<int> onToggleFavorite;
  final ValueChanged<ProductModel> onAddToCart;
  final double childAspectRatio;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final String? heroTagPrefix;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToCart,
    this.childAspectRatio = 0.60,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 14,
    this.mainAxisSpacing = 14,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 24),
    this.physics,
    this.shrinkWrap = false,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemBuilder: (context, index) {
        final item = products[index];
        return ProductCard(
          key: ValueKey('product-card-${item.id}'),
          product: item,
          heroTag: heroTagPrefix != null ? '$heroTagPrefix-${item.id}' : null,
          onTap: () => onTap(item),
          onToggleFavorite: () => onToggleFavorite(item.id),
          onAddToCart: () => onAddToCart(item),
        );
      },
    );
  }
}

// Sliver variant of ProductGrid for CustomScrollView integration.
class SliverProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onTap;
  final ValueChanged<int> onToggleFavorite;
  final ValueChanged<ProductModel> onAddToCart;
  final double childAspectRatio;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final String? heroTagPrefix;

  const SliverProductGrid({
    super.key,
    required this.products,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToCart,
    this.childAspectRatio = 0.60,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 14,
    this.mainAxisSpacing = 14,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 24),
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = products[index];
            return ProductCard(
              key: ValueKey('product-card-${item.id}'),
              product: item,
              heroTag: heroTagPrefix != null ? '$heroTagPrefix-${item.id}' : null,
              onTap: () => onTap(item),
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
