import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/bouncing_button.dart';
import '../providers/cart_provider.dart';
import '../../../core/utils/page_transitions.dart';
import '../../checkout/screens/checkout_screen.dart';

/// Professional shopping cart screen for Blue Panda.
/// Features studio product thumbnails, quantity steppers, item removal,
/// dynamic free shipping progress, order summary, and a sticky checkout bar.
class CartScreen extends StatelessWidget {
  final VoidCallback? onExplore;

  const CartScreen({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Empty Cart View
    if (cartProvider.isEmpty) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0B0F19)
            : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Shopping Cart',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
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
                    color: const Color(0xFF1E88E5).withValues(
                      alpha: isDark ? 0.18 : 0.08,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 52,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore trending tech, clothing, and audio gear to fill your cart.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 28),
                BouncingButton(
                  onTap: () {
                    if (onExplore != null) {
                      onExplore!();
                    } else {
                      Navigator.maybePop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Start Shopping',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
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

    // 2. Active Cart with Items
    final freeDeliveryProgress =
        (cartProvider.subtotal / 100.0).clamp(0.0, 1.0);
    final neededForFree = (100.0 - cartProvider.subtotal).clamp(0.0, 100.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0F19)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'My Cart (${cartProvider.totalItemsCount})',
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Cart',
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: Color(0xFFEF4444),
            ),
            onPressed: () => _confirmClearDialog(context, cartProvider),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable List of Cart Items and Order Summary
          ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 120 + bottomInset),
            physics: const BouncingScrollPhysics(),
            children: [
              // Free Shipping Progress Card
              _buildFreeShippingCard(
                neededForFree: neededForFree,
                progress: freeDeliveryProgress,
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Cart Items List
              ...List.generate(cartProvider.items.length, (index) {
                final item = cartProvider.items[index];
                return _buildCartItemCard(
                  context,
                  item: item,
                  index: index,
                  cartProvider: cartProvider,
                  isDark: isDark,
                  theme: theme,
                );
              }),

              const SizedBox(height: 8),

              // Order Summary Card
              _buildOrderSummaryCard(
                context,
                cartProvider: cartProvider,
                isDark: isDark,
              ),
            ],
          ),

          // Sticky Bottom Checkout Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildStickyCheckoutBar(
              context,
              cartProvider: cartProvider,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  // Free shipping incentive banner
  Widget _buildFreeShippingCard({
    required double neededForFree,
    required double progress,
    required bool isDark,
  }) {
    final isUnlocked = neededForFree <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
            : (isDark ? const Color(0xFF161F30) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUnlocked
                    ? Icons.check_circle_rounded
                    : Icons.local_shipping_outlined,
                size: 18,
                color: isUnlocked
                    ? const Color(0xFF10B981)
                    : const Color(0xFF1E88E5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isUnlocked
                      ? '🎉 You unlocked FREE Delivery!'
                      : 'Add \$${neededForFree.toStringAsFixed(2)} more for FREE shipping',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked
                        ? (isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF065F46))
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: isDark
                  ? const Color(0xFF253248)
                  : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? const Color(0xFF10B981) : const Color(0xFF1E88E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modern cart item card with thumbnail, title, price, stepper, and trash removal
  Widget _buildCartItemCard(
    BuildContext context, {
    required dynamic item,
    required int index,
    required CartProvider cartProvider,
    required bool isDark,
    required ThemeData theme,
  }) {
    final showVariant = item.variant != null &&
        item.variant.isNotEmpty &&
        item.variant != 'Standard';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F30) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Studio Product Thumbnail
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF253248)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: item.product.imageUrl.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 30,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    )
                  : Image.network(
                      item.product.imageUrl,
                      width: 76,
                      height: 76,
                      fit: BoxFit.contain,
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
                            width: 76,
                            height: 76,
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 30,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details & Actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Delete Action Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Single Item Direct Removal
                    GestureDetector(
                      key: Key('remove_cart_item_$index'),
                      onTap: () {
                        final removedName = item.product.name;
                        cartProvider.removeItem(index);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed $removedName from cart'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showVariant) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Option: ${item.variant}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Pricing and Quantity Stepper Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                          ),
                          if (item.quantity > 1) ...[
                            const SizedBox(height: 1),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '\$${item.product.price.toStringAsFixed(2)} each',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Modern Stepper ([-] Qty [+])
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF253248)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BouncingButton(
                            key: Key('cart_decrement_$index'),
                            onTap: () => cartProvider.decrementQuantity(index),
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF161F30)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.quantity == 1
                                    ? Icons.delete_outline_rounded
                                    : Icons.remove_rounded,
                                size: 14,
                                color: item.quantity == 1
                                    ? const Color(0xFFEF4444)
                                    : (isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${item.quantity}',
                              key: Key('cart_item_qty_$index'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          BouncingButton(
                            key: Key('cart_increment_$index'),
                            onTap: () => cartProvider.incrementQuantity(index),
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF161F30)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 14,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Order summary breakdown card
  Widget _buildOrderSummaryCard(
    BuildContext context, {
    required CartProvider cartProvider,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F30) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow(
            context,
            'Subtotal',
            '\$${cartProvider.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            context,
            'Delivery Fee',
            cartProvider.shippingFee == 0.0
                ? 'FREE'
                : '\$${cartProvider.shippingFee.toStringAsFixed(2)}',
            valueColor: cartProvider.shippingFee == 0.0
                ? const Color(0xFF10B981)
                : null,
          ),
          if (cartProvider.shippingFee > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Add \$${(100.0 - cartProvider.subtotal).toStringAsFixed(2)} more for FREE delivery',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: isDark
                  ? const Color(0xFF253248)
                  : const Color(0xFFF1F5F9),
            ),
          ),
          _summaryRow(
            context,
            'Total Amount',
            '\$${cartProvider.grandTotal.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  // Sticky bottom checkout button bar
  Widget _buildStickyCheckoutBar(
    BuildContext context, {
    required CartProvider cartProvider,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF161F30).withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF253248).withValues(alpha: 0.8)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: BouncingButton(
              onTap: () {
                Navigator.of(context).push(
                  SmoothPageRoute(page: const CheckoutScreen()),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• \$${cartProvider.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Summary breakdown row
  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : (isDark ? Colors.grey.shade400 : const Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 17 : 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: valueColor ??
                  (isBold
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? Colors.white : const Color(0xFF1E293B))),
            ),
          ),
        ),
      ],
    );
  }

  // Clear cart dialog
  void _confirmClearDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
