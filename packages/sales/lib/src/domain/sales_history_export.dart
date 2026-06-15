import 'models/sale_history_entry.dart';
import 'models/sales_history_filter.dart';
import 'models/sales_history_summary.dart';
import 'models/seller_option.dart';

const _paymentLabels = <String, String>{
  'cash': 'Наличные',
  'card': 'Карта',
};

/// Builds a CSV report for admin sales history.
String buildSalesHistoryCsv({
  required List<SaleHistoryEntry> entries,
  required SalesHistoryFilter filter,
  required List<SellerOption> sellers,
  required SalesHistorySummary summary,
}) {
  final buffer = StringBuffer()
    ..writeln('Отчёт по продажам')
    ..writeln(_filterDescription(filter, sellers))
    ..writeln()
    ..writeln('Продаж,${summary.saleCount}')
    ..writeln('Сумма,${summary.totalSum.toStringAsFixed(2)}')
    ..writeln('Средний чек,${summary.averageCheck.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('Дата,Сотрудник,Оплата,Сумма');

  for (final entry in entries) {
    final sale = entry.sale;
    final completedAt = sale.completedAt ?? sale.createdAt;
    final payment =
        _paymentLabels[sale.paymentMethod] ?? sale.paymentMethod ?? '';
    final seller = entry.sellerName.isNotEmpty ? entry.sellerName : sale.userId;

    buffer.writeln(
      '${_formatDateTime(completedAt)},'
      '${_escapeCsv(seller)},'
      '${_escapeCsv(payment)},'
      '${sale.sum?.toStringAsFixed(2) ?? '0.00'}',
    );
  }

  return buffer.toString();
}

String _filterDescription(
  SalesHistoryFilter filter,
  List<SellerOption> sellers,
) {
  if (!filter.hasActiveFilters) return 'Период: все продажи';

  final parts = <String>[];
  if (filter.fromDate != null) {
    parts.add('с ${_formatDate(filter.fromDate!)}');
  }
  if (filter.toDate != null) {
    parts.add('по ${_formatDate(filter.toDate!)}');
  }
  if (filter.userId != null) {
    final seller = sellers
        .where((option) => option.id == filter.userId)
        .firstOrNull;
    parts.add('сотрудник: ${seller?.displayName ?? filter.userId}');
  }

  return 'Фильтр: ${parts.join(', ')}';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.'
      '${local.month.toString().padLeft(2, '0')}.'
      '${local.year}';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${_formatDate(local)} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
