import 'stock_item.dart';

/// Aggregated warehouse metrics for the admin dashboard.
class StockDashboardMetrics {
  const StockDashboardMetrics({
    required this.totalPositions,
    required this.totalUnits,
    required this.lowStockCount,
    required this.zeroStockCount,
    required this.noAddressCount,
    required this.attentionItems,
  });

  final int totalPositions;
  final int totalUnits;
  final int lowStockCount;
  final int zeroStockCount;
  final int noAddressCount;
  final List<StockItem> attentionItems;

  factory StockDashboardMetrics.fromItems(List<StockItem> items) {
    var totalUnits = 0;
    var lowStockCount = 0;
    var zeroStockCount = 0;
    var noAddressCount = 0;
    final attentionItems = <StockItem>[];

    for (final item in items) {
      totalUnits += item.count;
      if (item.count == 0) zeroStockCount++;
      if (item.goodsAddr.isEmpty) noAddressCount++;
      if (item.isLowStock) {
        lowStockCount++;
        attentionItems.add(item);
      }
    }

    return StockDashboardMetrics(
      totalPositions: items.length,
      totalUnits: totalUnits,
      lowStockCount: lowStockCount,
      zeroStockCount: zeroStockCount,
      noAddressCount: noAddressCount,
      attentionItems: attentionItems,
    );
  }
}
