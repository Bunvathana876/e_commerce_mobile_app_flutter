import 'package:flutter/material.dart';

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

  // Parse category from JSON map
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '📦',
      itemCount: json['item_count'] as int? ?? 0,
      bgColor: json['bg_color'] != null
          ? Color(json['bg_color'] as int)
          : const Color(0xFF1E88E5),
      imageUrl: json['image_url'] as String? ?? '',
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
