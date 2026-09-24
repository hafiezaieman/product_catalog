import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/product_repository.dart';
import 'data/services/product_api_service.dart';
import 'presentation/providers/product_list_provider.dart';
import 'presentation/screens/product_list_screen.dart';

void main() {
  runApp(const ProductCatalogApp());
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductApiService>(create: (_) => ProductApiService()),
        Provider<ProductRepository>(
          create: (context) => ProductRepository(context.read<ProductApiService>()),
        ),
        ChangeNotifierProvider<ProductListProvider>(
          create: (context) => ProductListProvider(context.read<ProductRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Product Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}
