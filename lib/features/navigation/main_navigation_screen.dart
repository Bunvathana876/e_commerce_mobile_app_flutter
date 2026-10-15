import 'dart:ui';
import 'package:e_commerc_mobile_app/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/providers/cart_provider.dart';
import '../cart/screens/cart_screen.dart';
import '../categories/screens/categories_screen.dart';
import '../favorites/screens/favorites_screen.dart';
import '../products/providers/product_provider.dart';
import '../profile/screens/profile_screen.dart';

// Main app shell with bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Badge counts for cart and favorites
    final cartCount = context.watch<CartProvider>().totalItemsCount;
    final favCount = context.watch<ProductProvider>().totalFavoritesCount;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Navigation destinations
    final screens = [
      HomeScreen(
        onSeeAllCategories: () => setState(() => _currentIndex = 1),
      ),
      CategoriesScreen(
        onCategorySelected: (catId) {
          context.read<ProductProvider>().selectCategory(catId);
          setState(() => _currentIndex = 0);
        },
      ),
      FavoritesScreen(onExplore: () => setState(() => _currentIndex = 0)),
      CartScreen(onExplore: () => setState(() => _currentIndex = 0)),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: false,
      backgroundColor: isDark
          ? const Color(0xFF0B0F19)
          : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Subtle ambient glow in top safe area for depth without noise
          Positioned(
            top: -100,
            left: -40,
            right: -40,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E88E5).withValues(alpha: isDark ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Active tab screen
          IndexedStack(index: _currentIndex, children: screens),
        ],
      ),
      // Clean, modern floating-style frosted glass bottom navigation bar with notification badges
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF161F30).withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.94),
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
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem(
                      index: 0,
                      label: 'Home',
                      inactiveIcon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      isDark: isDark,
                    ),
                    _buildTabItem(
                      index: 1,
                      label: 'Categories',
                      inactiveIcon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view_rounded,
                      isDark: isDark,
                    ),
                    _buildTabItem(
                      index: 2,
                      label: 'Favorites',
                      inactiveIcon: Icons.favorite_outline_rounded,
                      activeIcon: Icons.favorite_rounded,
                      badgeCount: favCount,
                      isDark: isDark,
                    ),
                    _buildTabItem(
                      index: 3,
                      label: 'Cart',
                      inactiveIcon: Icons.shopping_bag_outlined,
                      activeIcon: Icons.shopping_bag_rounded,
                      badgeCount: cartCount,
                      isDark: isDark,
                    ),
                    _buildTabItem(
                      index: 4,
                      label: 'Profile',
                      inactiveIcon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData inactiveIcon,
    required IconData activeIcon,
    int badgeCount = 0,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF1E88E5);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.20 : 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                label: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFFEF4444),
                isLabelVisible: badgeCount > 0,
                child: AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    size: 23,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
