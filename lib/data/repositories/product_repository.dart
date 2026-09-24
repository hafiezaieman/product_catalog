import '../models/product.dart';
import '../models/product_page.dart';
import '../services/product_api_service.dart';

class ProductRepository {
  ProductRepository(this._apiService);

  final ProductApiService _apiService;

  Future<ProductPage> getProducts({required int limit, required int skip}) {
    return _apiService.fetchProducts(limit: limit, skip: skip);
  }

  Future<ProductPage> searchProducts({
    required String query,
    required int limit,
    required int skip,
  }) {
    return _apiService.searchProducts(query: query, limit: limit, skip: skip);
  }

  Future<Product> getProductDetail(int id) {
    return _apiService.fetchProductDetail(id);
  }
}
