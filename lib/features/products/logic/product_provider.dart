import 'package:flutter/material.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final repo = ProductRepository();

  List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await repo.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await repo.addProduct(product);
    await loadProducts();
  }
}