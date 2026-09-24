import 'product.dart';

class ProductPage {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? const [];
    return ProductPage(
      products: rawProducts
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? rawProducts.length,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? rawProducts.length,
    );
  }
}
