import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerc_mobile_app/shared/widgets/promo_banner_carousel.dart';
import 'package:e_commerc_mobile_app/shared/widgets/promo_banner.dart';

void main() {
  final testItems = [
    const PromoItem(
      titlePrefix: 'Get ',
      highlightText: '40% off',
      titleSuffix: ' your\nfirst order',
      subtitle: '+ \$0 delivery fee on orders \$15+',
      couponCode: 'FIRST40',
      buttonText: 'Order now',
    ),
    const PromoItem(
      titlePrefix: 'Up to ',
      highlightText: '50% off',
      titleSuffix: ' all\nelectronics',
      subtitle: 'Top tech & laptops',
      couponCode: 'TECH50',
      buttonText: 'Shop now',
      accentColor: Color(0xFF1E88E5),
    ),
    const PromoItem(
      titlePrefix: 'Flat ',
      highlightText: '30% off',
      titleSuffix: ' trending\nsneakers',
      subtitle: 'New sport drops',
      couponCode: 'KICKS30',
      buttonText: 'Explore',
      accentColor: Color(0xFFEA580C),
    ),
  ];

  Widget buildCarousel({
    List<PromoItem>? items,
    Duration autoScrollDuration = const Duration(seconds: 4),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PromoBannerCarousel(
          items: items ?? testItems,
          autoScrollDuration: autoScrollDuration,
        ),
      ),
    );
  }

  testWidgets('PromoBannerCarousel renders initial item and dots properly', (
    tester,
  ) async {
    await tester.pumpWidget(buildCarousel());
    await tester.pumpAndSettle();

    // Verify initial item is visible
    expect(find.textContaining('40% off', findRichText: true), findsOneWidget);
    expect(find.textContaining('FIRST40'), findsNothing);
    expect(find.text('Order now'), findsOneWidget);

    // Verify PromoBanner has activeDotIndex = 0 and totalDots = 3
    final bannerFinder = find.byType(PromoBanner);
    expect(bannerFinder, findsOneWidget);
    final banner = tester.widget<PromoBanner>(bannerFinder);
    expect(banner.activeDotIndex, 0);
    expect(banner.totalDots, 3);
  });

  testWidgets('PromoBannerCarousel auto-scrolls to next item after duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildCarousel(autoScrollDuration: const Duration(seconds: 4)),
    );
    await tester.pumpAndSettle();

    // Advance 4 seconds to trigger periodic timer
    await tester.pump(const Duration(seconds: 4));
    // Settle animation (Curves.easeInOutCubic, 650ms)
    await tester.pumpAndSettle();

    // Page 1 (Electronics 50% off) should now be active
    expect(find.textContaining('50% off', findRichText: true), findsOneWidget);
    expect(find.text('Shop now'), findsOneWidget);

    final banner = tester.widget<PromoBanner>(find.byType(PromoBanner));
    expect(banner.activeDotIndex, 1);

    // Advance another 4 seconds
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Page 2 (Sneakers 30% off) should now be active
    expect(find.textContaining('30% off', findRichText: true), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);

    final banner2 = tester.widget<PromoBanner>(find.byType(PromoBanner));
    expect(banner2.activeDotIndex, 2);

    // Advance another 4 seconds to test circular wrap-around to page 0
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.textContaining('40% off', findRichText: true), findsOneWidget);
    final banner3 = tester.widget<PromoBanner>(find.byType(PromoBanner));
    expect(banner3.activeDotIndex, 0);
  });

  testWidgets(
    'Manual swipe changes page, resets timer, and updates activeDotIndex',
    (tester) async {
      await tester.pumpWidget(
        buildCarousel(autoScrollDuration: const Duration(seconds: 4)),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('40% off', findRichText: true),
        findsOneWidget,
      );

      // Swipe left to advance to next page manually
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();

      // Page 1 should now be active
      expect(
        find.textContaining('50% off', findRichText: true),
        findsOneWidget,
      );
      final banner = tester.widget<PromoBanner>(find.byType(PromoBanner));
      expect(banner.activeDotIndex, 1);

      // Wait 2 seconds (less than 4s autoScrollDuration) - should stay on page 1
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('50% off', findRichText: true),
        findsOneWidget,
      );

      // Wait another 2 seconds (reaching full 4s from reset) - auto-scroll to page 2
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('30% off', findRichText: true),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'PromoBannerCarousel cleans up resources on dispose without error',
    (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      // Unmount the widget to trigger dispose()
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PromoBannerCarousel), findsNothing);
    },
  );

  testWidgets('PromoBannerCarousel handles empty list gracefully', (
    tester,
  ) async {
    await tester.pumpWidget(buildCarousel(items: []));
    await tester.pumpAndSettle();

    expect(find.byType(PromoBanner), findsNothing);
  });

  testWidgets('PromoBanner renders tag and badge when provided', (
    tester,
  ) async {
    const customItem = PromoItem(
      titlePrefix: 'Special ',
      highlightText: '25% off',
      titleSuffix: ' today',
      couponCode: 'SAVE25',
      tag: 'FLASH DEAL',
      tagIcon: Icons.bolt_rounded,
      badgeText: 'HOT',
    );

    await tester.pumpWidget(buildCarousel(items: [customItem]));
    await tester.pumpAndSettle();

    expect(find.text('FLASH DEAL'), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    expect(find.text('HOT'), findsOneWidget);
  });

  testWidgets('PromoBanner does not render promocode chips keeping UI clean', (
    tester,
  ) async {
    const customItem = PromoItem(
      highlightText: '10% off',
      couponCode: 'WELCOME10',
    );

    await tester.pumpWidget(buildCarousel(items: [customItem]));
    await tester.pumpAndSettle();

    // Verify coupon code is not rendered anywhere in the banner UI
    expect(find.textContaining('WELCOME10'), findsNothing);
    expect(find.textContaining('Code:'), findsNothing);
  });

  testWidgets('Tapping CTA button triggers onTap callback', (
    tester,
  ) async {
    var tapped = false;
    final customItem = PromoItem(
      highlightText: '10% off',
      buttonText: 'Shop now',
      onTap: () => tapped = true,
    );

    await tester.pumpWidget(buildCarousel(items: [customItem]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shop now'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
