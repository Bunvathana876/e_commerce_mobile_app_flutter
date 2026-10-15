import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../orders/models/order_model.dart';
import '../../orders/screens/order_detail_screen.dart';

/// Professional order success screen for Blue Panda.
/// Displays genuine order confirmation details:
/// Total paid, payment method, delivery city, and order status.
/// No fabricated order numbers or fake delivery estimates are shown.
class OrderSuccessScreen extends StatefulWidget {
  final double grandTotal;
  final String paymentMethod;
  final String addressCity;
  final String? orderId;
  final OrderModel? order;

  const OrderSuccessScreen({
    super.key,
    required this.grandTotal,
    required this.paymentMethod,
    required this.addressCity,
    this.orderId,
    this.order,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0F19)
          : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Animated checkmark badge with soft green glow
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(
                        alpha: isDark ? 0.2 : 0.12,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF34D399),
                              Color(0xFF059669),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Success title & message
                Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for your purchase. We are preparing your items for delivery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Real order receipt summary card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161F30) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF253248)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.04,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (widget.orderId != null && widget.orderId!.isNotEmpty) ...[
                        _infoRow(
                          'Order ID',
                          widget.orderId!,
                          isBold: true,
                          isDark: isDark,
                        ),
                        Divider(
                          height: 20,
                          color: isDark
                              ? const Color(0xFF253248)
                              : const Color(0xFFF1F5F9),
                        ),
                      ],
                      _infoRow(
                        'Order Status',
                        'Confirmed & Processing',
                        valueColor: const Color(0xFF10B981),
                        isBold: true,
                        isDark: isDark,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? const Color(0xFF253248)
                            : const Color(0xFFF1F5F9),
                      ),
                      _infoRow(
                        'Total Paid',
                        '\$${widget.grandTotal.toStringAsFixed(2)}',
                        valueColor: const Color(0xFF1E88E5),
                        isBold: true,
                        isDark: isDark,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? const Color(0xFF253248)
                            : const Color(0xFFF1F5F9),
                      ),
                      _infoRow(
                        'Payment Method',
                        widget.paymentMethod,
                        isDark: isDark,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? const Color(0xFF253248)
                            : const Color(0xFFF1F5F9),
                      ),
                      _infoRow(
                        'Delivering To',
                        widget.addressCity,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // View Order Details button (when genuine order record is present)
                if (widget.order != null) ...[
                  BouncingButton(
                    key: const Key('view_order_details_button'),
                    onTap: () {
                      Navigator.of(context).push(
                        SmoothPageRoute(
                          page: OrderDetailScreen(order: widget.order!),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161F30) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1E88E5),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            color: Color(0xFF1E88E5),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'View Order Details',
                            style: TextStyle(
                              color: Color(0xFF1E88E5),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Continue Shopping action button
                BouncingButton(
                  key: const Key('continue_shopping_button'),
                  onTap: () {
                    // Navigate back to the main navigation shell
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.mainNav,
                      (route) => false,
                    );
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              color: Colors.white,
                              size: 19,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Continue Shopping',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Key-value metadata row with flexible wrapping
  Widget _infoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    bool isDark = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ??
                  (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ],
    );
  }
}
