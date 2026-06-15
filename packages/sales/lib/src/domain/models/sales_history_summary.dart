import 'sale_history_entry.dart';

/// Aggregated metrics for a set of completed sales.
class SalesHistorySummary {
  const SalesHistorySummary({
    required this.saleCount,
    required this.totalSum,
  });

  final int saleCount;
  final double totalSum;

  double get averageCheck => saleCount == 0 ? 0 : totalSum / saleCount;

  factory SalesHistorySummary.fromEntries(List<SaleHistoryEntry> entries) {
    var total = 0.0;
    for (final entry in entries) {
      total += entry.sale.sum ?? 0;
    }

    return SalesHistorySummary(
      saleCount: entries.length,
      totalSum: total,
    );
  }
}
