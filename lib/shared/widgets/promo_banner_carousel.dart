import 'dart:async';
import 'package:flutter/material.dart';
import 'promo_banner.dart';

/// Data model representing an individual promotional item in the banner carousel.
class PromoItem {
  final String titlePrefix;
  final String highlightText;
  final String titleSuffix;
  final String subtitle;
  final String couponCode;
  final String buttonText;
  final String? imageUrl;
  final String? assetPath;
  final VoidCallback? onTap;
  final Color accentColor;

  const PromoItem({
    this.titlePrefix = 'Get ',
    required this.highlightText,
    this.titleSuffix = '',
    this.subtitle = '',
    this.couponCode = '',
    this.buttonText = 'Order now',
    this.imageUrl,
    this.assetPath,
    this.onTap,
    this.accentColor = const Color(0xFF008744),
  });
}

/// An auto-scrolling promotional banner carousel built purely with Flutter primitives.
///
/// Features:
/// - Smooth automatic page progression using [PageController] and [Timer.periodic].
/// - Resets timer countdown upon manual user gestures.
/// - Synchronizes active dot pagination indicator with the currently displayed page.
/// - Cleans up timer and controller resources properly in [dispose].
class PromoBannerCarousel extends StatefulWidget {
  final List<PromoItem> items;
  final Duration autoScrollDuration;
  final double height;

  const PromoBannerCarousel({
    super.key,
    required this.items,
    this.autoScrollDuration = const Duration(seconds: 4),
    this.height = 191.0,
  });

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScrollTimer();
  }

  @override
  void didUpdateWidget(covariant PromoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoScrollDuration != widget.autoScrollDuration ||
        oldWidget.items.length != widget.items.length) {
      _startAutoScrollTimer();
    }
  }

  /// Starts or restarts the auto-scrolling periodic timer.
  void _startAutoScrollTimer() {
    _autoScrollTimer?.cancel();

    // No need to auto-scroll if there's only 1 item or list is empty
    if (widget.items.length <= 1) return;

    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (!mounted || !_pageController.hasClients) return;

      final nextPage = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  /// Handles page changes whether initiated automatically or via user swipe.
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // Reset countdown so the user has full duration to read the swiped page
    _startAutoScrollTimer();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            // Pause timer while user is actively touching or dragging
            _autoScrollTimer?.cancel();
          } else if (notification is ScrollEndNotification) {
            // Restart timer once user interaction finishes
            _startAutoScrollTimer();
          }
          return false;
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.items.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final item = widget.items[index];

            return PromoBanner(
              titlePrefix: item.titlePrefix,
              highlightText: item.highlightText,
              titleSuffix: item.titleSuffix,
              subtitle: item.subtitle,
              couponCode: item.couponCode,
              buttonText: item.buttonText,
              imageUrl: item.imageUrl,
              assetPath: item.assetPath,
              onTap: item.onTap,
              accentColor: item.accentColor,
              activeDotIndex: _currentPage,
              totalDots: widget.items.length,
            );
          },
        ),
      ),
    );
  }
}

