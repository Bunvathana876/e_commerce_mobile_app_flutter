import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Navigation item model for [IosBottomNavBar].
class IosNavItem {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final int? badgeCount;

  const IosNavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    this.badgeCount,
  });
}

/// A clean, minimalist iOS-style bottom navigation bar with rounded corners,
/// soft drop shadow, 5 tabs, and an iOS home indicator pill.
class IosBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IosNavItem>? items;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;
  final Color homeIndicatorColor;
  final bool showHomeIndicator;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  const IosBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
    this.backgroundColor = Colors.white,
    this.activeColor = const Color(0xFF1A1A1A),
    this.inactiveColor = const Color(0xFF9E9E9E),
    this.borderColor = const Color(0xFFF1F5F9),
    this.homeIndicatorColor = const Color(0xFF1A1A1A),
    this.showHomeIndicator = true,
    this.margin,
    this.borderRadius,
  });

  /// The 5 default navigation tabs matching the iOS minimalist design.
  static const List<IosNavItem> defaultItems = [
    IosNavItem(
      label: 'Home',
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
    ),
    IosNavItem(
      label: 'Search',
      activeIcon: Icons.search_rounded,
      inactiveIcon: Icons.search_rounded,
    ),
    IosNavItem(
      label: 'Post',
      activeIcon: CupertinoIcons.square_pencil,
      inactiveIcon: CupertinoIcons.square_pencil,
    ),
    IosNavItem(
      label: 'Notifications',
      activeIcon: Icons.favorite_rounded,
      inactiveIcon: Icons.favorite_border_rounded,
    ),
    IosNavItem(
      label: 'Profile',
      activeIcon: Icons.account_circle_rounded,
      inactiveIcon: Icons.account_circle_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final navItems = items ?? defaultItems;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(28),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: !showHomeIndicator,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row of 5 evenly spaced navigation tabs
              Row(
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = index == currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      // Eliminates default Material splash ripples for a clean iOS feel
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tab icon with optional badge
                          _buildTabIcon(item, isSelected),
                          const SizedBox(height: 6),
                          // Tab label
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected ? activeColor : inactiveColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              // Bottom iOS Home Indicator Pill
              if (showHomeIndicator) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: homeIndicatorColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon(IosNavItem item, bool isSelected) {
    final iconWidget = Icon(
      isSelected ? item.activeIcon : item.inactiveIcon,
      size: 26,
      color: isSelected ? activeColor : inactiveColor,
    );

    if (item.badgeCount != null && item.badgeCount! > 0) {
      return Badge(
        label: Text(
          item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFEF4444),
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}

/// A complete, self-contained Stateful demo screen utilizing [IosBottomNavBar].
class IosBottomNavExampleScreen extends StatefulWidget {
  const IosBottomNavExampleScreen({super.key});

  @override
  State<IosBottomNavExampleScreen> createState() =>
      _IosBottomNavExampleScreenState();
}

class _IosBottomNavExampleScreenState extends State<IosBottomNavExampleScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = const [
    'Home',
    'Search',
    'Post',
    'Notifications',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _tabTitles[_currentIndex],
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: Center(
        child: Text(
          '${_tabTitles[_currentIndex]} Screen',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ),
      bottomNavigationBar: IosBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

