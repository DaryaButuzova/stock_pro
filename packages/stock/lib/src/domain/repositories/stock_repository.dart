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
}
