import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/product_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Товары')),
      body: ListView.builder(
        itemCount: provider.products.length,
        itemBuilder: (context, index) {
          final product = provider.products[index];

          return ListTile(
            title: Text(product.name),
            subtitle: Text('Остаток: ${product.quantity}'),
            trailing: Text('${product.price} €'),
          );
        },
      ),
    );
  }
}