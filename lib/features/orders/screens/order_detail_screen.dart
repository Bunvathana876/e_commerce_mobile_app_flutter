import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../models/order_model.dart';

/// Professional Order Details screen in Blue Panda.
/// Displays genuine order records, item breakdown, payment status,
/// truthful status progress timeline, and delivery address.
class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161F30) : Colors.white;
    final borderColor = isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Order ${order.formattedOrderId}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Order Status & Visual Progress Timeline Card
          _buildStatusTimelineCard(
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            subColor: subColor,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // 2. Purchased Items Review Card
          _buildItemsCard(
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            subColor: subColor,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // 3. Delivery Details Card
          _buildDeliveryCard(
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            subColor: subColor,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // 4. Payment Info Card
          _buildPaymentCard(
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            subColor: subColor,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // 5. Price Breakdown Card
          _buildPriceBreakdownCard(
            cardBg: cardBg,
            borderColor: borderColor,
            titleColor: titleColor,
            subColor: subColor,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Continue Shopping Button
          BouncingButton(
            key: const Key('order_detail_continue_shopping'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.mainNav,
                (route) => false,
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
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Continue Shopping',
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
    );
  }

  // 1. Status & Timeline
  Widget _buildStatusTimelineCard({
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subColor,
    required bool isDark,
  }) {
    final statusLower = order.status.toLowerCase();
    Color badgeColor;
    Color badgeBg;
    String statusTitle;

    switch (statusLower) {
      case 'delivered':
        badgeColor = const Color(0xFF10B981);
        badgeBg = const Color(0xFF10B981).withValues(alpha: isDark ? 0.22 : 0.12);
        statusTitle = 'Delivered';
        break;
      case 'shipped':
        badgeColor = const Color(0xFF0284C7);
        badgeBg = const Color(0xFF0284C7).withValues(alpha: isDark ? 0.22 : 0.12);
        statusTitle = 'Shipped & En Route';
        break;
      case 'processing':
        badgeColor = const Color(0xFF1E88E5);
        badgeBg = const Color(0xFF1E88E5).withValues(alpha: isDark ? 0.22 : 0.12);
        statusTitle = 'Processing Order';
        break;
      case 'cancelled':
        badgeColor = const Color(0xFFEF4444);
        badgeBg = const Color(0xFFEF4444).withValues(alpha: isDark ? 0.22 : 0.12);
        statusTitle = 'Cancelled';
        break;
      case 'pending':
      default:
        badgeColor = const Color(0xFFD97706);
        badgeBg = const Color(0xFFD97706).withValues(alpha: isDark ? 0.22 : 0.12);
        statusTitle = 'Confirmed & Processing';
        break;
    }

    // Step index: 0 = Placed, 1 = Processing, 2 = Shipped, 3 = Delivered
    int activeStep = 1;
    if (statusLower == 'pending') activeStep = 1;
    if (statusLower == 'processing') activeStep = 1;
    if (statusLower == 'shipped') activeStep = 2;
    if (statusLower == 'delivered') activeStep = 3;
    if (statusLower == 'cancelled') activeStep = 0;

    final steps = ['Order Placed', 'Processing', 'Shipped', 'Delivered'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.formattedOrderId,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(fontSize: 12, color: subColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4-step Horizontal Progress Timeline
          if (statusLower != 'cancelled') ...[
            Row(
              children: List.generate(steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  final stepIdx = index ~/ 2;
                  final isDone = stepIdx < activeStep;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color: isDone
                          ? const Color(0xFF1E88E5)
                          : (isDark
                                ? const Color(0xFF253248)
                                : const Color(0xFFE2E8F0)),
                    ),
                  );
                } else {
                  final stepIdx = index ~/ 2;
                  final isCompleted = stepIdx <= activeStep;
                  final isCurrent = stepIdx == activeStep;

                  return Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF1E88E5)
                          : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0)),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF60A5FA)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      size: 12,
                      color: isCompleted
                          ? Colors.white
                          : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    ),
                  );
                }
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(steps.length, (idx) {
                final isReached = idx <= activeStep;
                return Expanded(
                  child: Text(
                    steps[idx],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isReached ? FontWeight.w700 : FontWeight.w500,
                      color: isReached
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : subColor,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live GPS tracking is not available for standard delivery. Standard courier dispatch in progress.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 2. Items Card
  Widget _buildItemsCard({
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${order.items.length})',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(order.items.length, (index) {
            final item = order.items[index];
            final isLast = index == order.items.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.inventory_2_outlined,
                                size: 20,
                                color: subColor,
                              ),
                            )
                          : Icon(
                              Icons.inventory_2_outlined,
                              size: 20,
                              color: subColor,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & qty
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 3. Delivery Card
  Widget _buildDeliveryCard({
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF1E88E5), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.shippingAddress.isNotEmpty
                ? order.shippingAddress
                : 'Phnom Penh, Cambodia',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Payment Card
  Widget _buildPaymentCard({
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Payment Information',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _metaRow(
            'Method',
            order.paymentMethod,
            titleColor: titleColor,
            subColor: subColor,
          ),
          const SizedBox(height: 8),
          _metaRow(
            'Payment Status',
            order.isPaid ? 'Paid' : 'Unpaid (On Delivery)',
            valueColor: order.isPaid
                ? const Color(0xFF10B981)
                : const Color(0xFFD97706),
            isBold: true,
            titleColor: titleColor,
            subColor: subColor,
          ),
        ],
      ),
    );
  }

  // 5. Price Breakdown Card
  Widget _buildPriceBreakdownCard({
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
              color: titleColor,
            ),
          ),
          const SizedBox(height: 12),
          _metaRow(
            'Subtotal',
            '\$${order.subtotal.toStringAsFixed(2)}',
            titleColor: titleColor,
            subColor: subColor,
          ),
          const SizedBox(height: 8),
          _metaRow(
            'Shipping Fee',
            order.shippingFee == 0.0
                ? 'FREE'
                : '\$${order.shippingFee.toStringAsFixed(2)}',
            valueColor: order.shippingFee == 0.0 ? const Color(0xFF10B981) : null,
            titleColor: titleColor,
            subColor: subColor,
          ),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _metaRow(
              'Discount',
              '-\$${order.discountAmount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF10B981),
              titleColor: titleColor,
              subColor: subColor,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: isDark ? const Color(0xFF253248) : const Color(0xFFF1F5F9),
            ),
          ),
          _metaRow(
            'Total Paid',
            '\$${order.total.toStringAsFixed(2)}',
            isBold: true,
            fontSize: 16,
            valueColor: const Color(0xFF1E88E5),
            titleColor: titleColor,
            subColor: subColor,
          ),
        ],
      ),
    );
  }

  Widget _metaRow(
    String label,
    String value, {
    bool isBold = false,
    double? fontSize,
    Color? valueColor,
    required Color titleColor,
    required Color subColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14.5 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? titleColor : subColor,
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
              fontSize: fontSize ?? (isBold ? 15 : 13),
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: valueColor ?? titleColor,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} • $hour:$min $period';
  }
}
