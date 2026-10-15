import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../orders/screens/order_history_screen.dart';
import '../../products/providers/product_provider.dart';
import '../settings/screens/settings_screen.dart';

// Profile screen displaying account information, stats, settings, and logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    OrderProvider? orderProvider;
    try {
      orderProvider = context.watch<OrderProvider>();
    } catch (_) {
      // In isolated widget tests where OrderProvider might not be injected
    }
    final activeOrdersCount = orderProvider?.activeOrdersCount ?? 0;
    final user = authProvider.currentUser;

    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Bun Vathana';
    final displayEmail = user?.email.isNotEmpty == true
        ? user!.email
        : 'student@example.com';
    final roleName = (user?.role ?? 'customer').toUpperCase();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(SmoothPageRoute(page: const SettingsScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: [
          // User profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161F30) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF253248)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with Camera Edit Badge
                Stack(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Name, Email & Role Tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: Color(0xFF1E88E5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        displayEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Membership Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$roleName MEMBER',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? const Color(0xFF93C5FD)
                                    : const Color(0xFF2563EB),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick account summary cards
          Row(
            children: [
              _buildStatCard(
                title: 'Orders',
                value: '$activeOrdersCount Active',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF1E88E5),
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(page: const OrderHistoryScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                title: 'Wishlist',
                value: '${productProvider.totalFavoritesCount} Saved',
                icon: Icons.favorite_border_rounded,
                color: const Color(0xFFEF4444),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                title: 'Cart',
                value: '${cartProvider.totalItemsCount} Items',
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Orders and shopping navigation
          _buildSectionHeader('Orders & Shopping', isDark),
          const SizedBox(height: 8),
          _buildCardGroup([
            _buildProfileTile(
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFF1E88E5),
              title: 'My Orders',
              subtitle: 'Track active deliveries & view history',
              isDark: isDark,
              badge: activeOrdersCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$activeOrdersCount Active',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.of(context).push(
                  SmoothPageRoute(page: const OrderHistoryScreen()),
                );
              },
            ),
            Divider(
              height: 1,
              indent: 56,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            _buildProfileTile(
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFFF59E0B),
              title: 'Shipping Addresses',
              subtitle: 'Phnom Penh, Cambodia (Default)',
              isDark: isDark,
              onTap: () => _showShippingAddressesSheet(context, isDark),
            ),
            Divider(
              height: 1,
              indent: 56,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            _buildProfileTile(
              icon: Icons.credit_card_outlined,
              iconColor: const Color(0xFF10B981),
              title: 'Payment Methods',
              subtitle: 'ABA KHQR, Visa / Mastercard',
              isDark: isDark,
              onTap: () => _showPaymentMethodsSheet(context, isDark),
            ),
          ], isDark),
          const SizedBox(height: 22),

          // Preferences and security navigation
          _buildSectionHeader('Preferences & Security', isDark),
          const SizedBox(height: 8),
          _buildCardGroup([
            _buildProfileTile(
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFF1E88E5),
              title: 'App Settings',
              subtitle: 'Dark mode, currency, language & cache',
              isDark: isDark,
              onTap: () {
                Navigator.of(
                  context,
                ).push(SmoothPageRoute(page: const SettingsScreen()));
              },
            ),
            Divider(
              height: 1,
              indent: 56,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 22,
                ),
              ),
              title: Text(
                'Push Notifications',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                'Receive instant status updates on orders',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                activeTrackColor: const Color(0xFF1E88E5),
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
              ),
            ),
            Divider(
              height: 1,
              indent: 56,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            _buildProfileTile(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF0284C7),
              title: 'Account Security',
              subtitle: 'Password, biometric login & sessions',
              isDark: isDark,
              onTap: () => _showAccountSecuritySheet(context, isDark),
            ),
            Divider(
              height: 1,
              indent: 56,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            _buildProfileTile(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFF64748B),
              title: 'Help Center & Support',
              subtitle: 'FAQ, contact support & chat',
              isDark: isDark,
              onTap: () => _showHelpCenterSheet(context, isDark),
            ),
          ], isDark),
          const SizedBox(height: 24),

          // Logout button
          BouncingButton(
            onTap: () => _showLogoutDialog(context, authProvider),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.25)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                      : const Color(0xFFFCA5A5),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Color(0xFFDC2626),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App version footer
          Center(
            child: Text(
              'Blue Panda E-Commerce • v1.0.0 (Build 2026)',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F30) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? badge,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: isDark ? 0.20 : 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 21),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[badge, const SizedBox(width: 8)],
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isDark ? Colors.grey.shade500 : const Color(0xFF94A3B8),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: BouncingButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161F30) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.20 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom sheets

  void _showShippingAddressesSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161F30) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Shipping Addresses',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAddressTile(
                label: 'Home',
                recipient: 'Bun Vathana (+855 12 345 678)',
                address: 'Street 271, Sangkat Boeung Tumpun, Phnom Penh, Cambodia',
                isDefault: true,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildAddressTile(
                label: 'Office',
                recipient: 'Bun Vathana (+855 98 765 432)',
                address: 'Russian Blvd, Canadia Bank Tower, 18th Floor, Phnom Penh',
                isDefault: false,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTile({
    required String label,
    required String recipient,
    required String address,
    required bool isDefault,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
              ? const Color(0xFF1E88E5)
              : (isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0)),
          width: isDefault ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            recipient,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            address,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161F30) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.credit_card_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Supported Payment Methods',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPaymentMethodTile(
                icon: Icons.qr_code_2_rounded,
                title: 'ABA KHQR Pay',
                subtitle: 'Scan and pay instantly with Bakong / ABA Mobile',
                status: 'Active',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildPaymentMethodTile(
                icon: Icons.credit_card_outlined,
                title: 'Credit / Debit Card',
                subtitle: 'Visa, Mastercard, UnionPay, JCB',
                status: 'Supported',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildPaymentMethodTile(
                icon: Icons.local_atm_outlined,
                title: 'Cash on Delivery (COD)',
                subtitle: 'Pay cash upon receiving your delivery',
                status: 'Available',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountSecuritySheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF0284C7),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Account Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFF1E88E5),
              ),
              title: Text(
                'Change Password',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                'Update your current account password',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password reset instructions sent to your email!',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.fingerprint_rounded,
                color: Color(0xFF10B981),
              ),
              title: Text(
                'Biometric Authentication',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                'Fast sign-in with Face ID or fingerprint',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Biometric authentication is active for this device!',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpCenterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF64748B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Help & Customer Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF1E88E5),
              ),
              title: Text(
                'Live Chat with Support',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                'Available 24/7 for order questions',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support agent will connect shortly.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.mail_outline_rounded,
                color: Color(0xFFF59E0B),
              ),
              title: Text(
                'Email Support',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                'support@bluepanda.com',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact support at support@bluepanda.com'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Logout confirmation dialog

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of Blue Panda? You will need to log in again to view your saved addresses and orders.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Clear cached orders from OrderProvider
              try {
                Provider.of<OrderProvider>(context, listen: false).clearOrders();
              } catch (_) {}
              // Clear user state & token
              authProvider.logout();
              // Reset navigation back to Welcome screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.welcome,
                (route) => false,
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
