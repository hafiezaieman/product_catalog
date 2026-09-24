import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_page.dart';

class ProductApiException implements Exception {
  final String message;
  ProductApiException(this.message);

  @override
  String toString() => message;
}

class ProductApiService {
  ProductApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://dummyjson.com';

  final http.Client _client;
  final String _baseUrl;

  Future<ProductPage> fetchProducts({int limit = 20, int skip = 0}) {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
    return _getPage(uri);
  }

  Future<ProductPage> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) {
    final uri = Uri.parse('$_baseUrl/products/search').replace(
      queryParameters: {
        'q': query,
        'limit': '$limit',
        'skip': '$skip',
      },
    );
    return _getPage(uri);
  }

  Future<Product> fetchProductDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    final body = await _get(uri);
    return Product.fromJson(body);
  }

  Future<ProductPage> _getPage(Uri uri) async {
    final body = await _get(uri);
    return ProductPage.fromJson(body);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ProductApiException('Request timed out. Check your connection and try again.');
    } catch (_) {
      throw ProductApiException('Could not reach the server. Check your connection.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductApiException('Server error (${response.statusCode}). Please try again.');
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ProductApiException('Received an unexpected response from the server.');
    }
  }
}
