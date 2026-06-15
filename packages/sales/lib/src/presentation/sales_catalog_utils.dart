import 'package:local_reference_feature/local_reference_feature.dart';

/// Filters in-stock catalog goods for the sales add-item sheet.
List<Goods> filterAvailableCatalogGoods({
  required List<Goods> catalogGoods,
  required Map<String, int> stockByGoodsId,
  String searchQuery = '',
  String? category,
}) {
  Iterable<Goods> result = catalogGoods.where(
    (goods) => (stockByGoodsId[goods.id] ?? 0) > 0,
  );

  if (category != null && category.isNotEmpty) {
    result = result.where((goods) => goods.category == category);
  }

  final query = searchQuery.trim().toLowerCase();
  if (query.isNotEmpty) {
    result = result.where((goods) {
      final name = goods.displayName.toLowerCase();
      final description = (goods.description ?? '').toLowerCase();
      final goodsCategory = (goods.category ?? '').toLowerCase();
      return name.contains(query) ||
          description.contains(query) ||
          goodsCategory.contains(query);
    });
  }

  return result.toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));
}

/// Distinct non-empty categories from catalog goods, sorted alphabetically.
List<String> extractCatalogCategories(List<Goods> catalogGoods) {
  return catalogGoods
      .map((goods) => goods.category)
      .whereType<String>()
      .where((category) => category.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}
