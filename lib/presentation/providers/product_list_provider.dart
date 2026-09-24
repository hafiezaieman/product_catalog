import 'package:flutter/foundation.dart';

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/product_api_service.dart';

enum ProductListState { loading, error, empty, success }

class ProductListProvider extends ChangeNotifier {
  ProductListProvider(this._repository);

  final ProductRepository _repository;
  static const int _pageSize = 20;

  ProductListState state = ProductListState.loading;
  List<Product> products = [];
  String errorMessage = '';

  bool isLoadingMore = false;

  bool hasLoadMoreError = false;

  int _skip = 0;
  int _total = 0;
  String _query = '';

  bool get isSearching => _query.isNotEmpty;
  bool get hasMore => _skip < _total;

  Future<void> loadInitial() async {
    state = ProductListState.loading;
    hasLoadMoreError = false;
    notifyListeners();

    try {
      final page = await _fetchPage(skip: 0);
      products = page.products;
      _total = page.total;
      _skip = page.products.length;
      state = products.isEmpty ? ProductListState.empty : ProductListState.success;
    } on ProductApiException catch (e) {
      errorMessage = e.message;
      state = ProductListState.error;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      state = ProductListState.error;
    }
    notifyListeners();
  }

  
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || state != ProductListState.success) return;

    isLoadingMore = true;
    hasLoadMoreError = false;
    notifyListeners();

    try {
      final page = await _fetchPage(skip: _skip);
      products = [...products, ...page.products];
      _total = page.total;
      _skip += page.products.length;
    } catch (_) {
      hasLoadMoreError = true;
    }

    isLoadingMore = false;
    notifyListeners();
  }

  void search(String query) {
    final trimmed = query.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    loadInitial();
  }

  Future<void> retry() => loadInitial();

  Future<void> refresh() => loadInitial();

  Future<ProductPageResult> _fetchPage({required int skip}) async {
    final page = _query.isEmpty
        ? await _repository.getProducts(limit: _pageSize, skip: skip)
        : await _repository.searchProducts(query: _query, limit: _pageSize, skip: skip);
    return ProductPageResult(products: page.products, total: page.total);
  }
}

class ProductPageResult {
  final List<Product> products;
  final int total;
  ProductPageResult({required this.products, required this.total});
}
