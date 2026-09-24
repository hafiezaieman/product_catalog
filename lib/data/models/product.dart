/// Domain/data model for a single product.
///
/// Only the fields the UI actually needs are parsed out of the DummyJSON
/// response; everything else is ignored. All fields are defensively parsed
/// (with fallbacks) since DummyJSON's shape has some optional fields.
class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double discountPercentage;
  final double rating;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: (json['brand'] as String?) ?? '',
      price: _toDouble(json['price']),
      discountPercentage: _toDouble(json['discountPercentage']),
      rating: _toDouble(json['rating']),
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
