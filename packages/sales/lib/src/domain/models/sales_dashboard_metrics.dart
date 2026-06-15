import 'sale_history_entry.dart';
import 'sales_history_summary.dart';

/// Extended metrics for the admin sales dashboard.
class SalesDashboardMetrics {
  const SalesDashboardMetrics({
    required this.summary,
    required this.todayCount,
    required this.todaySum,
    required this.cashCount,
    required this.cardCount,
    required this.cashSum,
    required this.cardSum,
    required this.maxSaleAmount,
    this.topSellerName,
    this.topSellerCount = 0,
  });

  final SalesHistorySummary summary;
  final int todayCount;
  final double todaySum;
  final int cashCount;
  final int cardCount;
  final double cashSum;
  final double cardSum;
  final double maxSaleAmount;
  final String? topSellerName;
  final int topSellerCount;

  int get saleCount => summary.saleCount;
  double get totalSum => summary.totalSum;
  double get averageCheck => summary.averageCheck;

  double get cashShare => saleCount == 0 ? 0 : cashCount / saleCount;
  double get cardShare => saleCount == 0 ? 0 : cardCount / saleCount;

  factory SalesDashboardMetrics.fromEntries(List<SaleHistoryEntry> entries) {
    final summary = SalesHistorySummary.fromEntries(entries);
    final today = DateTime.now();
    var todayCount = 0;
    var todaySum = 0.0;
    var cashCount = 0;
    var cardCount = 0;
    var cashSum = 0.0;
    var cardSum = 0.0;
    var maxSaleAmount = 0.0;
    final sellerCounts = <String, int>{};

    for (final entry in entries) {
      final sale = entry.sale;
      final amount = sale.sum ?? 0;
      final completedAt = (sale.completedAt ?? sale.createdAt).toLocal();

      if (_isSameDay(completedAt, today)) {
        todayCount++;
        todaySum += amount;
      }

      if (sale.paymentMethod == 'cash') {
        cashCount++;
        cashSum += amount;
      } else if (sale.paymentMethod == 'card') {
        cardCount++;
        cardSum += amount;
      }

      if (amount > maxSaleAmount) {
        maxSaleAmount = amount;
      }

      final sellerKey = entry.sellerName.isNotEmpty
          ? entry.sellerName
          : sale.userId;
      sellerCounts[sellerKey] = (sellerCounts[sellerKey] ?? 0) + 1;
    }

    String? topSellerName;
    var topSellerCount = 0;
    for (final entry in sellerCounts.entries) {
      if (entry.value > topSellerCount) {
        topSellerCount = entry.value;
        topSellerName = entry.key;
      }
    }

    return SalesDashboardMetrics(
      summary: summary,
      todayCount: todayCount,
      todaySum: todaySum,
      cashCount: cashCount,
      cardCount: cardCount,
      cashSum: cashSum,
      cardSum: cardSum,
      maxSaleAmount: maxSaleAmount,
      topSellerName: topSellerName,
      topSellerCount: topSellerCount,
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
