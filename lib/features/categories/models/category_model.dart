import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final int itemCount;
  final Color bgColor;
  final String imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.itemCount = 0,
    this.bgColor = const Color(0xFF1E88E5),
    this.imageUrl = '',
  });

  static String _categoryIconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('shoe') || lower.contains('sneaker')) return '👟';
    if (lower.contains('electronic') ||
        lower.contains('laptop') ||
        lower.contains('gadget')) {
      return '💻';
    }
    if (lower.contains('fashion') ||
        lower.contains('cloth') ||
        lower.contains('apparel')) {
      return '👕';
    }
    if (lower.contains('watch')) return '⌚';
    if (lower.contains('audio') ||
        lower.contains('headphone') ||
        lower.contains('sound')) {
      return '🎧';
    }
    if (lower.contains('bag') || lower.contains('backpack')) return '🎒';
    if (lower.contains('game') || lower.contains('gaming')) return '🎮';
    if (lower.contains('beauty') || lower.contains('cosmetic')) return '✨';
    return '📦';
  }

  // Parse category from JSON map
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Category';
    final rawIcon = json['icon'] as String?;
    final icon = (rawIcon != null && rawIcon.isNotEmpty)
        ? rawIcon
        : _categoryIconFor(name);

    final rawImage =
        json['image_url'] as String? ?? json['image'] as String? ?? '';
    final normalizedImage = ApiEndpoints.normalizeImageUrl(rawImage);

    return CategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: name,
      icon: icon,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      bgColor: json['bg_color'] != null
          ? Color(json['bg_color'] as int)
          : const Color(0xFF1E88E5),
      imageUrl: normalizedImage,
    );
  }

  // Convert category to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'item_count': itemCount,
      'image_url': imageUrl,
    };
  }
}
