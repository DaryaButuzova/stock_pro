import 'package:local_reference_feature/local_reference_feature.dart';

import 'models/stock_movement.dart';
import 'models/stock_movement_filter.dart';
import 'models/stock_movement_summary.dart';
import 'stock_list_utils.dart';

/// Builds a CSV report for the stock movement journal.
String buildStockMovementCsv({
  required List<StockMovement> movements,
  required Map<String, Goods> goodsById,
  required StockMovementSummary summary,
  required StockMovementTypeFilter typeFilter,
  String? goodsName,
}) {
  final buffer = StringBuffer()
    ..writeln('Журнал движений товаров')
    ..writeln(_filterDescription(typeFilter: typeFilter, goodsName: goodsName))
    ..writeln()
    ..writeln('Записей,${summary.totalCount}')
    ..writeln('Сегодня пополнено,+${summary.todayReplenishment}')
    ..writeln('Сегодня списано,−${summary.todayWriteOff}')
    ..writeln('Сегодня продажи,−${summary.todaySales}')
    ..writeln(
      'Изменение за день,'
      '${summary.todayNetChange >= 0 ? '+' : ''}'
      '${summary.todayNetChange}',
    )
    ..writeln()
    ..writeln('Дата,Тип,Количество,Товар,Сотрудник,Комментарий');

  for (final movement in movements) {
    final goodsLabel =
        goodsById[movement.goodsId]?.displayName ??
        shortId(movement.goodsId);
    final actor = movement.actorName ?? movement.userId ?? '';
    final countLabel = movement.count > 0
        ? '+${movement.count}'
        : '${movement.count}';

    buffer.writeln(
      '${_formatDateTime(movement.createdAt)},'
      '${_escapeCsv(movement.typeLabel)},'
      '$countLabel,'
      '${_escapeCsv(goodsLabel)},'
      '${_escapeCsv(actor)},'
      '${_escapeCsv(movement.comment ?? '')}',
    );
  }

  return buffer.toString();
}

String buildStockMovementCsvFromLoaded({
  required List<StockMovement> movements,
  required Map<String, Goods> goodsById,
  required StockMovementSummary summary,
  required StockMovementTypeFilter typeFilter,
  String? filterGoodsId,
}) {
  return buildStockMovementCsv(
    movements: movements,
    goodsById: goodsById,
    summary: summary,
    typeFilter: typeFilter,
    goodsName: filterGoodsId == null
        ? null
        : goodsById[filterGoodsId]?.displayName,
  );
}

String _filterDescription({
  required StockMovementTypeFilter typeFilter,
  String? goodsName,
}) {
  final parts = <String>[];
  if (goodsName != null && goodsName.isNotEmpty) {
    parts.add('товар: $goodsName');
  } else {
    parts.add('все товары');
  }
  if (typeFilter != StockMovementTypeFilter.all) {
    parts.add('тип: ${typeFilter.label}');
  }
  return 'Фильтр: ${parts.join(', ')}';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final date =
      '${local.day.toString().padLeft(2, '0')}.'
      '${local.month.toString().padLeft(2, '0')}.'
      '${local.year}';
  final time =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}

String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
