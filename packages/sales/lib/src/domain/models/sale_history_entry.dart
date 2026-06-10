import 'sale.dart';

/// Completed sale row for admin history, with seller display name.
class SaleHistoryEntry {
  const SaleHistoryEntry({
    required this.sale,
    required this.sellerName,
  });

  final Sale sale;
  final String sellerName;

  factory SaleHistoryEntry.fromJson(Map<String, dynamic> json) {
    final users = json['users'];
    var sellerName = '';
    if (users is Map<String, dynamic>) {
      sellerName = users['creds'] as String? ?? '';
    }

    final saleJson = Map<String, dynamic>.from(json)..remove('users');

    return SaleHistoryEntry(
      sale: Sale.fromJson(saleJson),
      sellerName: sellerName,
    );
  }
}
