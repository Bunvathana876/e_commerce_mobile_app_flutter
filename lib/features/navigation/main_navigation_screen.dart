import 'package:e_commerc_mobile_app/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/providers/cart_provider.dart';
import '../cart/screens/cart_screen.dart';
import '../categories/screens/categories_screen.dart';
import '../favorites/screens/favorites_screen.dart';
import '../products/providers/product_provider.dart';
import '../profile/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalItemsCount;
    final favCount = context.watch<ProductProvider>().totalFavoritesCount;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const HomeScreen(),
      CategoriesScreen(
        onCategorySelected: (catId) {
          context.read<ProductProvider>().selectCategory(catId);
          setState(() => _currentIndex = 0);
        },
      ),
      FavoritesScreen(onExplore: () => setState(() => _currentIndex = 0)),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: false,
      body: Stack(
        children: [
          // 1. Permanent Universal Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_all_screens.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          if (isDark)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A).withValues(alpha: 0.88),
              ),
            ),

          // 2. Active Screen (Transparent Scaffold on top)
          IndexedStack(index: _currentIndex, children: screens),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.92),
        elevation: 6,
        indicatorColor: const Color(0xFF1E88E5).withValues(alpha: isDark ? 0.3 : 0.15),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF1E88E5)),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(
              Icons.grid_view_rounded,
              color: Color(0xFF1E88E5),
            ),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$favCount'),
              isLabelVisible: favCount > 0,
              child: const Icon(Icons.favorite_outline_rounded),
            ),
            selectedIcon: Badge(
              label: Text('$favCount'),
              isLabelVisible: favCount > 0,
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFF1E88E5),
              ),
            ),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Color(0xFF1E88E5),
              ),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF1E88E5)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
