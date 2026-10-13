import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bouncing_button.dart';

// Promotional card banner with headline, coupon code, image, and CTA button.
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
  final String? tag;
  final IconData? tagIcon;
  final String? badgeText;

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
    this.accentColor = const Color(0xFF008744),
    this.activeDotIndex = 0,
    this.totalDots = 4,
    this.tag,
    this.tagIcon,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.grey.shade400 : const Color(0xFF475569);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  Colors.white,
                  Color.lerp(Colors.white, accentColor, 0.08) ?? Colors.white,
                ],
        ),
        border: Border.all(
          color: isDark
              ? accentColor.withValues(alpha: 0.28)
              : accentColor.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Decorative ambient radial glow in the top-right corner
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: isDark ? 0.35 : 0.22),
                      accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Decorative outline ring
            Positioned(
              right: -45,
              top: -45,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.12 : 0.07),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Decorative subtle ambient glow in bottom-left
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
                      accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Floating 3D product showcase card (Right side)
            Positioned(
              right: 6,
              top: 14,
              bottom: 14,
              width: 145,
              child: Center(
                child: Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    width: 122,
                    height: 122,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.white,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17.5),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildBannerImage(),
                          if (badgeText != null && badgeText!.isNotEmpty)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 0.6,
                                  ),
                                ),
                                child: Text(
                                  badgeText!.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Promotional headline, perks, coupon, and action button (Left side)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 150, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Upper Tag Pill
                  if (tag != null && tag!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: accentColor.withValues(alpha: isDark ? 0.4 : 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tagIcon != null) ...[
                            Icon(tagIcon, size: 10, color: accentColor),
                            const SizedBox(width: 3.5),
                          ],
                          Text(
                            tag!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Headline with highlight accent
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
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

                  // Subtitle & Interactive Voucher Chip
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                      if (couponCode.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: couponCode));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Coupon "$couponCode" copied to clipboard!'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.14)
                                    : const Color(0xFFCBD5E1),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 11,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark
                                          ? Colors.grey.shade300
                                          : const Color(0xFF334155),
                                    ),
                                    children: [
                                      const TextSpan(text: 'Code: '),
                                      TextSpan(
                                        text: couponCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 9.5,
                                  color: isDark
                                      ? Colors.grey.shade500
                                      : const Color(0xFF94A3B8),
                                ),
                              ],
                            ),
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
                        horizontal: 14,
                        vertical: 7.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            Color.lerp(accentColor, Colors.black, 0.15) ?? accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.35),
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
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel pagination dots
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(totalDots, (index) {
                    final isActive = index == activeDotIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: isActive ? 18 : 6,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive
                            ? accentColor
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.22)
                                : Colors.black.withValues(alpha: 0.14)),
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
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(),
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor,
              ),
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.local_offer_rounded,
          size: 26,
          color: accentColor,
        ),
      ),
    );
  }
}
