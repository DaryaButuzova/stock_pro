import '../../../core/database/app_db.dart';
import 'product_model.dart';

class ProductRepository {
  final dbProvider = AppDb.instance;

  Future<void> addProduct(Product product) async {
    final db = await dbProvider.database;

    await db.insert(
      'products',
      product.toMap(),
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await dbProvider.database;

    final result = await db.query('products');

    return result.map((e) => Product.fromMap(e)).toList();
  }
}