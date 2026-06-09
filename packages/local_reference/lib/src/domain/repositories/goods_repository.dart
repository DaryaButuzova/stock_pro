import '../models/goods.dart';

/// Local read access to cached reference data.
abstract class GoodsRepository {
  /// Returns all cached goods ordered by name.
  Future<List<Goods>> getAll();

  /// Returns a single goods item by id, or null if not cached.
  Future<Goods?> getById(String id);
}
