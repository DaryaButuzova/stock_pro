import '../models/stock_item.dart';

/// Contract for warehouse stock data access.
///
/// Implementations may use Supabase, local storage, REST API, etc.
abstract class StockRepository {
  /// Returns all stock records.
  Future<List<StockItem>> getStockItems();
}
