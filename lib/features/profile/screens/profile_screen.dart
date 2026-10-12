import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../products/providers/product_provider.dart';
import '../settings/screens/settings_screen.dart';

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
              Navigator.of(context).push(
                SmoothPageRoute(page: const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: [
          // 1. User Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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

          // 2. Quick Account Stats Row
          Row(
            children: [
              _buildStatCard(
                title: 'Orders',
                value: '2 Active',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF1E88E5),
                isDark: isDark,
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

          // 3. Section: Orders & Payments
          _buildSectionHeader('Orders & Shopping', isDark),
          const SizedBox(height: 8),
          _buildCardGroup([
            _buildProfileTile(
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFF1E88E5),
              title: 'My Orders',
              subtitle: 'Track active deliveries & view history',
              isDark: isDark,
              badge: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '2 Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order tracking screen is next!'),
                    behavior: SnackBarBehavior.floating,
                  ),
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Address management coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment methods management coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ], isDark),
          const SizedBox(height: 22),

          // 4. Section: Preferences & Security
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
                Navigator.of(context).push(
                  SmoothPageRoute(page: const SettingsScreen()),
                );
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
              onTap: () {},
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
              onTap: () {},
            ),
          ], isDark),
          const SizedBox(height: 24),

          // 5. Working Logout Button
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

          // App Version Footer
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

  // --- Helper Widgets ---

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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
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
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Working Logout Flow ---

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
