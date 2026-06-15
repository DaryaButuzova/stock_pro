import 'package:local_reference_feature/local_reference_feature.dart';

import 'models/stock_item.dart';
import 'models/stock_positions_filter.dart';

/// Label for goods without a category in the reference catalog.
const uncategorizedCategoryLabel = 'Без категории';

/// A collapsible group of warehouse positions sharing the same goods category.
class StockCategoryGroup {
  const StockCategoryGroup({
    required this.categoryLabel,
    required this.items,
  });

  final String categoryLabel;
  final List<StockItem> items;

  bool get hasLowStock => items.any((item) => item.isLowStock);
}

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
    final goods = goodsById[item.goodsId];
    final goodsName = goods?.displayName.toLowerCase() ?? '';
    final address = item.goodsAddr.toLowerCase();
    final category = goodsCategoryLabel(goods).toLowerCase();
    return goodsName.contains(query) ||
        address.contains(query) ||
        category.contains(query);
  }).toList();
}

/// Groups stock items by goods category, sorted alphabetically.
List<StockCategoryGroup> groupStockItemsByCategory({
  required List<StockItem> items,
  required Map<String, Goods> goodsById,
}) {
  final grouped = <String, List<StockItem>>{};

  for (final item in items) {
    final label = goodsCategoryLabel(goodsById[item.goodsId]);
    grouped.putIfAbsent(label, () => []).add(item);
  }

  final labels = grouped.keys.toList()
    ..sort((a, b) {
      if (a == uncategorizedCategoryLabel) return 1;
      if (b == uncategorizedCategoryLabel) return -1;
      return a.compareTo(b);
    });

  return labels
      .map(
        (label) => StockCategoryGroup(
          categoryLabel: label,
          items: grouped[label]!
            ..sort(
              (a, b) => stockItemTitle(a, goodsById)
                  .compareTo(stockItemTitle(b, goodsById)),
            ),
        ),
      )
      .toList();
}

/// Whether grouped stock lists should expand all visible sections.
bool shouldExpandAllStockCategories({
  required List<StockCategoryGroup> groups,
  required String searchQuery,
  required StockPositionsFilter filter,
}) {
  if (searchQuery.trim().isNotEmpty) return true;
  if (filter != StockPositionsFilter.all) return true;
  return groups.length <= 3;
}

/// Default expanded category labels for a grouped stock list.
Set<String> defaultExpandedStockCategories(List<StockCategoryGroup> groups) {
  if (shouldExpandAllStockCategories(
    groups: groups,
    searchQuery: '',
    filter: StockPositionsFilter.all,
  )) {
    return groups.map((group) => group.categoryLabel).toSet();
  }

  return groups
      .where((group) => group.hasLowStock)
      .map((group) => group.categoryLabel)
      .toSet();
}

String goodsCategoryLabel(Goods? goods) {
  final category = goods?.category?.trim();
  if (category != null && category.isNotEmpty) return category;
  return uncategorizedCategoryLabel;
}

String stockItemTitle(StockItem item, Map<String, Goods> goodsById) {
  if (item.goodsAddr.isNotEmpty) return item.goodsAddr;
  return goodsById[item.goodsId]?.displayName ?? shortId(item.goodsId);
}

String stockItemSubtitle(StockItem item, Map<String, Goods> goodsById) {
  final goods = goodsById[item.goodsId];
  final category = goods?.category?.trim();
  final hasCategory = category != null && category.isNotEmpty;
  final goodsName = goods?.displayName;
  final addressInTitle = item.goodsAddr.isNotEmpty;

  if (addressInTitle) {
    final namePart = goodsName ?? shortId(item.goodsId);
    return hasCategory ? '$category · $namePart' : namePart;
  }

  if (hasCategory) return category;
  if (goodsName != null) return goodsName;
  return 'Без адреса';
}

String shortId(String id) {
  if (id.length <= 8) return id;
  return '${id.substring(0, 8)}…';
}
