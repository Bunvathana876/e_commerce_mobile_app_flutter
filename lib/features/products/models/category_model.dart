class CategoryModel {
  final int id;
  final String name;
  final String icon;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
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

    return CategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: name,
      icon: icon,
    );
  }
}
