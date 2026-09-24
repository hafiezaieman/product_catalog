import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/product_api_service.dart';
import '../widgets/network_thumbnail.dart';
import '../widgets/state_views.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Product> _load() {
    final repository = context.read<ProductRepository>();
    return repository.getProductDetail(widget.productId);
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Product>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ProductApiException
                ? (snapshot.error as ProductApiException).message
                : 'Something went wrong. Please try again.';
            return ErrorView(message: message, onRetry: _retry);
          }
          final product = snapshot.data;
          if (product == null) {
            return const EmptyView(message: 'Product not found.');
          }
          return _ProductDetailBody(product: product);
        },
      ),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final images = product.images.isNotEmpty ? product.images : [product.thumbnail];

    return RefreshIndicator(
      onRefresh: () async {}, // detail is single-shot; pull-to-refresh here is a no-op for now
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SizedBox(
            height: 260,
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: NetworkThumbnail(url: images[index], borderRadius: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                if (product.brand.isNotEmpty)
                  Text(product.brand, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(product.rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Description', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
