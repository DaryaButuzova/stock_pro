import 'package:local_reference_feature/local_reference_feature.dart';

import 'models/stock_item.dart';
import 'models/stock_positions_filter.dart';

/// Filters stock items by status and search query.
List<StockItem> filterStockItems({
  required List<StockItem> items,
  required Map<String, Goods> goodsById,
  StockPositionsFilter filter = StockPositionsFilter.all,
  String searchQuery = '',
}) {
  Iterable<StockItem> result = items;

  result = switch (filter) {
    StockPositionsFilter.all => result,
    StockPositionsFilter.lowStock => result.where((item) => item.isLowStock),
    StockPositionsFilter.zeroStock => result.where((item) => item.count == 0),
    StockPositionsFilter.noAddress =>
      result.where((item) => item.goodsAddr.isEmpty),
  };

  final query = searchQuery.trim().toLowerCase();
  if (query.isEmpty) return result.toList();

  return result.where((item) {
    final goodsName =
        goodsById[item.goodsId]?.displayName.toLowerCase() ?? '';
    final address = item.goodsAddr.toLowerCase();
    return goodsName.contains(query) || address.contains(query);
  }).toList();
}

String stockItemTitle(StockItem item, Map<String, Goods> goodsById) {
  if (item.goodsAddr.isNotEmpty) return item.goodsAddr;
  return goodsById[item.goodsId]?.displayName ?? shortId(item.goodsId);
}

String stockItemSubtitle(StockItem item, Map<String, Goods> goodsById) {
  final goodsName = goodsById[item.goodsId]?.displayName;
  if (item.goodsAddr.isNotEmpty && goodsName != null) {
    return goodsName;
  }
  if (goodsName != null) return goodsName;
  return 'Без адреса';
}

String shortId(String id) {
  if (id.length <= 8) return id;
  return '${id.substring(0, 8)}…';
}
