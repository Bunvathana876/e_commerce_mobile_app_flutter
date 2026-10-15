import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/bouncing_button.dart';
import '../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BouncingButton(
      onTap: onTap,
      scaleFactor: 0.97,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Thumbnail with Floating Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.45,
                    child: category.imageUrl.isNotEmpty
                        ? Image.network(
                            category.imageUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 350,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) {
                                return child;
                              }
                              return Shimmer.fromColors(
                                baseColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                                highlightColor: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFFFFFFF),
                                child: Container(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                ),
                              );
                            },
                            errorBuilder: (_, _, _) => Container(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFE2E8F0),
                              alignment: Alignment.center,
                              child: Text(
                                category.icon,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          )
                        : Container(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFE2E8F0),
                            alignment: Alignment.center,
                            child: Text(
                              category.icon,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                  ),
                ),

                // Floating Emoji Icon Badge (Bottom-Right of Image)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Category Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Item count & Arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF253248)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${category.itemCount} items',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade300
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: Color(0xFF1E88E5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
