import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'bouncing_button.dart';

/// Clean, human-crafted promotional banner card with editorial headline,
/// lifestyle imagery, and tactile CTA button.
class PromoBanner extends StatelessWidget {
  final String? title;
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
    this.title,
    this.titlePrefix = '',
    this.highlightText = '',
    this.titleSuffix = '',
    this.subtitle = '',
    this.couponCode = '',
    this.buttonText = 'Explore',
    this.imageUrl,
    this.assetPath,
    this.onTap,
    this.accentColor = const Color(0xFF059669),
    this.activeDotIndex = 0,
    this.totalDots = 3,
    this.tag,
    this.tagIcon,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 185,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  Color.lerp(Colors.white, accentColor, 0.04) ?? Colors.white,
                ],
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155).withValues(alpha: 0.6)
              : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Right Side: Clean, architectural image showcase
            Positioned(
              right: 12,
              top: 12,
              bottom: 12,
              width: 138,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildBannerImage(),
                      // Subtle inner border for crisp edge definition
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : Colors.black.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                      ),
                      // Refined badge if provided
                      if (badgeText != null && badgeText!.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A).withValues(alpha: 0.88)
                                  : Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.black.withValues(alpha: 0.06),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              badgeText!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Left Side: Content area with clean typographic hierarchy
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 158, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Upper category / tag pill
                  if (tag != null && tag!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tagIcon != null) ...[
                            Icon(tagIcon, size: 10, color: accentColor),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            tag!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Headline
                  _buildHeadline(titleColor),

                  // Subtitle
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: subColor,
                        height: 1.3,
                      ),
                    ),

                  // Tactile CTA Button
                  BouncingButton(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7.5,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.28),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
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
                      width: isActive ? 16 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive
                            ? accentColor
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.20)
                                : Colors.black.withValues(alpha: 0.12)),
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

  Widget _buildHeadline(Color titleColor) {
    if (title != null && title!.isNotEmpty) {
      return Text(
        title!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: titleColor,
          height: 1.2,
          letterSpacing: -0.4,
        ),
      );
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: titleColor,
          height: 1.2,
          letterSpacing: -0.4,
        ),
        children: [
          if (titlePrefix.isNotEmpty) TextSpan(text: titlePrefix),
          if (highlightText.isNotEmpty)
            TextSpan(
              text: highlightText,
              style: TextStyle(color: accentColor),
            ),
          if (titleSuffix.isNotEmpty) TextSpan(text: titleSuffix),
        ],
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
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Shimmer.fromColors(
            baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            highlightColor: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 24,
          color: accentColor,
        ),
      ),
    );
  }
}
