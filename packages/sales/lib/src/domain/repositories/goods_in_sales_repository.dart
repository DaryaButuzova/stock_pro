import '../models/goods_in_sale.dart';

/// Persistence for cart line items in `public.goods_in_sales`.
abstract class GoodsInSalesRepository {
  /// Returns all items for the given sale, newest first.
  Future<List<GoodsInSale>> getBySaleId(String saleId);

  /// Adds a new line or updates count/cost for an existing goods row.
  Future<GoodsInSale> addOrUpdateItem({
    required String saleId,
    required String goodsId,
    required int count,
    required double cost,
  });

  /// Updates quantity for an existing line item.
  Future<GoodsInSale> updateCount({
    required String itemId,
    required int count,
  });

  /// Removes a line item from the cart.
  Future<void> removeItem(String itemId);
}
