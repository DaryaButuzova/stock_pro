import '../models/stock_item.dart';

/// Contract for warehouse stock data access.
///
/// Implementations may use Supabase, local storage, REST API, etc.
abstract class StockRepository {
  /// Returns all stock records.
  Future<List<StockItem>> getStockItems();

  /// Adds quantity to a stock record (admin only).
  Future<StockItem> replenishStock({
    required String goodsId,
    required int count,
    String? comment,
  });

  /// Removes quantity from a stock record (admin only).
  Future<StockItem> writeOffStock({
    required String goodsId,
    required int count,
    String? comment,
  });

  /// Updates warehouse address and minimum threshold (admin only).
  Future<StockItem> updateStockMeta({
    required String goodsId,
    required String goodsAddr,
    required int minCount,
  });

  /// Creates a stock row for an existing goods item (admin only).
  Future<StockItem> createStockPosition({
    required String goodsId,
    required String goodsAddr,
    required int minCount,
  });

  /// Deletes a stock row when quantity is zero (admin only).
  Future<void> deleteStockPosition(String goodsId);
}
