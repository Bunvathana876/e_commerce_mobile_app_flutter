class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int discountPercent;
  final double rating;
  final int reviewCount;
  final int categoryId;
  final String imageUrl;
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPercent = 0,
    required this.rating,
    required this.reviewCount,
    required this.categoryId,
    required this.imageUrl,
    this.isFavorite = false,
  });

  ProductModel copyWith({bool? isFavorite}) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      rating: rating,
      reviewCount: reviewCount,
      categoryId: categoryId,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
