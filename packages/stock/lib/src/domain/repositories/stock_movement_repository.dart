import '../models/stock_movement.dart';

/// Contract for reading stock movement history.
abstract class StockMovementRepository {
  /// Returns movements ordered by newest first.
  Future<List<StockMovement>> getMovements({
    String? goodsId,
    int limit = 200,
  });
}
