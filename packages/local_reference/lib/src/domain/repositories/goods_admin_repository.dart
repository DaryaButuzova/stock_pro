import '../models/goods.dart';

/// Remote admin mutations for the goods catalog.
abstract class GoodsAdminRepository {
  /// Creates a goods record and an empty stock row.
  Future<Goods> create({
    required String name,
    String? description,
    double? cost,
    String? category,
  });

  /// Updates an existing goods record.
  Future<Goods> update({
    required String id,
    required String name,
    String? description,
    double? cost,
    String? category,
  });

  /// Deletes a goods record.
  Future<void> delete(String id);
}
