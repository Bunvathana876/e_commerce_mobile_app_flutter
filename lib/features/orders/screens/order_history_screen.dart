import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';

/// Modern Order History screen in Blue Panda.
/// Displays genuine customer order records, order status badges,
/// formatted dates, total amounts, and seamless navigation to details.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Orders',
            icon: const Icon(Icons.refresh_rounded, size: 21),
            onPressed: () => orderProvider.fetchOrders(forceRefresh: true),
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProvider.fetchOrders(forceRefresh: true),
        color: const Color(0xFF1E88E5),
        child: orders.isEmpty
            ? _buildEmptyOrdersState(isDark)
            : _buildOrdersList(orders, isDark, titleColor, subColor),
      ),
    );
  }

  // Truthful empty state with helpful "Start Shopping" action
  Widget _buildEmptyOrdersState(bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF161F30)
                  : const Color(0xFFEFF6FF),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF253248)
                    : const Color(0xFFDBEAFE),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 46,
              color: Color(0xFF1E88E5),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'When you place an order, your items, receipts, and delivery updates will appear right here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: BouncingButton(
            key: const Key('order_history_start_shopping_button'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.mainNav,
                (route) => false,
              );
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 28),
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront_outlined, color: Colors.white, size: 18),
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
        ),
      ],
    );
  }

  // Active list of orders
  Widget _buildOrdersList(
    List<OrderModel> orders,
    bool isDark,
    Color titleColor,
    Color subColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, isDark, titleColor, subColor);
      },
    );
  }

  Widget _buildOrderCard(
    OrderModel order,
    bool isDark,
    Color titleColor,
    Color subColor,
  ) {
    final statusLower = order.status.toLowerCase();
    Color statusColor;
    Color statusBg;

    switch (statusLower) {
      case 'delivered':
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0xFF10B981).withValues(alpha: isDark ? 0.22 : 0.12);
        break;
      case 'shipped':
        statusColor = const Color(0xFF0284C7);
        statusBg = const Color(0xFF0284C7).withValues(alpha: isDark ? 0.22 : 0.12);
        break;
      case 'processing':
        statusColor = const Color(0xFF1E88E5);
        statusBg = const Color(0xFF1E88E5).withValues(alpha: isDark ? 0.22 : 0.12);
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0xFFEF4444).withValues(alpha: isDark ? 0.22 : 0.12);
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFD97706).withValues(alpha: isDark ? 0.22 : 0.12);
        break;
    }

    final cardBg = isDark ? const Color(0xFF161F30) : Colors.white;
    final borderColor = isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              SmoothPageRoute(page: OrderDetailScreen(order: order)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Order ID + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E88E5).withValues(
                                alpha: isDark ? 0.22 : 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_outlined,
                              size: 17,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              order.formattedOrderId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        order.displayStatus,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Item description / thumbnail preview
                if (order.items.isNotEmpty) ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 36,
                          height: 36,
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          child: order.items.first.imageUrl != null &&
                                  order.items.first.imageUrl!.isNotEmpty
                              ? Image.network(
                                  order.items.first.imageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.inventory_2_outlined,
                                    size: 16,
                                    color: subColor,
                                  ),
                                )
                              : Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: subColor,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.items.first.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${order.totalItemUnits} ${order.totalItemUnits == 1 ? "item" : "items"} • ${order.paymentMethod}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF253248)
                      : const Color(0xFFF1F5F9),
                ),
                const SizedBox(height: 10),

                // Footer: Date and Total Price + Chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(order.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: subColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: subColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    return '$month ${dt.day}, ${dt.year}';
  }
}
