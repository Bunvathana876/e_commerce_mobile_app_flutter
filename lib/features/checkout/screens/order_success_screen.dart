import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../shared/widgets/bouncing_button.dart';

class OrderSuccessScreen extends StatefulWidget {
  final double grandTotal;
  final String paymentMethod;
  final String addressCity;

  const OrderSuccessScreen({
    super.key,
    required this.grandTotal,
    required this.paymentMethod,
    required this.addressCity,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = 'BP-${10000 + Random().nextInt(90000)}';

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
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // 1. Animated Success Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Headline & Subtitle
              Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for your order. We have sent a confirmation email with tracking details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),

              // 3. Order Details Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    _infoRow('Order ID', _orderId, isBold: true, isDark: isDark),
                    Divider(
                      height: 20,
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    _infoRow(
                      'Payment Method',
                      widget.paymentMethod,
                      isDark: isDark,
                    ),
                    Divider(
                      height: 20,
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    _infoRow(
                      'Delivering To',
                      widget.addressCity,
                      isDark: isDark,
                    ),
                    Divider(
                      height: 20,
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    _infoRow(
                      'Estimated Delivery',
                      '1 - 3 Business Days',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 4. Action Button
              BouncingButton(
                onTap: () {
                  // Navigate back to the persistent main navigation and reset stack
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.mainNav,
                    (route) => false,
                  );
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

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
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color:
                valueColor ??
                (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
