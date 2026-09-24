import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:product_catalog/data/repositories/product_repository.dart';
import 'package:product_catalog/data/services/product_api_service.dart';

void main() {
  group('ProductRepository', () {
    test('getProducts parses a successful list response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/products');
        expect(request.url.queryParameters['limit'], '20');
        expect(request.url.queryParameters['skip'], '0');

        return http.Response(
          jsonEncode({
            'products': [
              {
                'id': 1,
                'title': 'Essence Mascara Lash Princess',
                'description': 'A mascara.',
                'category': 'beauty',
                'brand': 'Essence',
                'price': 9.99,
                'discountPercentage': 7.17,
                'rating': 4.94,
                'thumbnail': 'https://example.com/thumb.jpg',
                'images': ['https://example.com/1.jpg'],
              },
            ],
            'total': 194,
            'skip': 0,
            'limit': 20,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository = ProductRepository(ProductApiService(client: mockClient));
      final page = await repository.getProducts(limit: 20, skip: 0);

      expect(page.total, 194);
      expect(page.products, hasLength(1));
      expect(page.products.first.title, 'Essence Mascara Lash Princess');
      expect(page.products.first.price, 9.99);
    });

    test('searchProducts hits the search endpoint with the query param', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/products/search');
        expect(request.url.queryParameters['q'], 'phone');

        return http.Response(
          jsonEncode({'products': [], 'total': 0, 'skip': 0, 'limit': 20}),
          200,
        );
      });

      final repository = ProductRepository(ProductApiService(client: mockClient));
      final page = await repository.searchProducts(query: 'phone', limit: 20, skip: 0);

      expect(page.products, isEmpty);
      expect(page.total, 0);
    });

    test('throws ProductApiException on a non-2xx response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final repository = ProductRepository(ProductApiService(client: mockClient));

      expect(
        () => repository.getProducts(limit: 20, skip: 0),
        throwsA(isA<ProductApiException>()),
      );
    });

    test('getProductDetail parses a single product', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/products/42');
        return http.Response(
          jsonEncode({
            'id': 42,
            'title': 'iPhone 9',
            'description': 'An iPhone.',
            'category': 'smartphones',
            'brand': 'Apple',
            'price': 549.0,
            'discountPercentage': 12.96,
            'rating': 4.69,
            'thumbnail': 'https://example.com/iphone.jpg',
            'images': ['https://example.com/iphone1.jpg', 'https://example.com/iphone2.jpg'],
          }),
          200,
        );
      });

      final repository = ProductRepository(ProductApiService(client: mockClient));
      final product = await repository.getProductDetail(42);

      expect(product.id, 42);
      expect(product.title, 'iPhone 9');
      expect(product.images, hasLength(2));
    });
  });
}
