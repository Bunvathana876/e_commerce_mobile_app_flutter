import 'package:flutter/material.dart';
import 'bouncing_button.dart';

class PromoBanner extends StatelessWidget {
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
  final int activeDotIndex;
  final int totalDots;

  const PromoBanner({
    super.key,
    this.titlePrefix = 'Get ',
    this.highlightText = '40% off',
    this.titleSuffix = ' your\nfirst order',
    this.subtitle = '+ \$0 delivery fee on orders \$15+',
    this.couponCode = 'GET40',
    this.buttonText = 'Order now',
    this.imageUrl,
    this.assetPath,
    this.onTap,
    this.accentColor = const Color(0xFF008744), // Emerald green matching design
    this.activeDotIndex = 0,
    this.totalDots = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F7F4);
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE5EDE8);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.grey.shade400 : const Color(0xFF475569);
    final codeTextColor =
        isDark ? Colors.grey.shade300 : const Color(0xFF334155);
    final codeColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final inactiveDotColor =
        isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 175,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. Right-side Overlapping Plate/Product Image
            Positioned(
              right: -25,
              top: -15,
              bottom: -15,
              width: 200,
              child: _buildBannerImage(),
            ),

            // 2. Left-side Promotional Text & Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 140, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Headline with Highlight
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                      children: [
                        TextSpan(text: titlePrefix),
                        TextSpan(
                          text: highlightText,
                          style: TextStyle(color: accentColor),
                        ),
                        TextSpan(text: titleSuffix),
                      ],
                    ),
                  ),

                  // Subtitles and Coupon code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                      if (couponCode.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: codeTextColor,
                            ),
                            children: [
                              const TextSpan(text: 'Use code '),
                              TextSpan(
                                text: couponCode,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: codeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Pill CTA Button
                  BouncingButton(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Carousel Pagination Indicators (Bottom-Center/Right)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(totalDots, (index) {
                    final isActive = index == activeDotIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 14 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? accentColor : inactiveDotColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _fallbackImage(),
      );
    }

    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_offer_rounded,
          size: 56,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
