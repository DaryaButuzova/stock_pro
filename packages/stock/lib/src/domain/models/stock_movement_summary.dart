import 'stock_movement.dart';

/// Aggregated movement metrics for the journal header.
class StockMovementSummary {
  const StockMovementSummary({
    required this.totalCount,
    required this.todayReplenishment,
    required this.todayWriteOff,
    required this.todaySales,
    required this.todayNetChange,
  });

  final int totalCount;
  final int todayReplenishment;
  final int todayWriteOff;
  final int todaySales;
  final int todayNetChange;

  factory StockMovementSummary.fromMovements(List<StockMovement> movements) {
    final today = DateTime.now();
    var todayReplenishment = 0;
    var todayWriteOff = 0;
    var todaySales = 0;
    var todayNetChange = 0;

    for (final movement in movements) {
      if (!_isSameDay(movement.createdAt.toLocal(), today)) continue;

      todayNetChange += movement.count;
      switch (movement.movementType) {
        case 'replenishment_in':
          todayReplenishment += movement.count;
        case 'write_off':
          todayWriteOff += movement.count.abs();
        case 'sale_out':
          todaySales += movement.count.abs();
      }
    }

    return StockMovementSummary(
      totalCount: movements.length,
      todayReplenishment: todayReplenishment,
      todayWriteOff: todayWriteOff,
      todaySales: todaySales,
      todayNetChange: todayNetChange,
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// A day bucket for timeline rendering.
class StockMovementDayGroup {
  const StockMovementDayGroup({
    required this.label,
    required this.movements,
  });

  final String label;
  final List<StockMovement> movements;
}

List<StockMovementDayGroup> groupMovementsByDay(
  List<StockMovement> movements,
) {
  if (movements.isEmpty) return const [];

  final groups = <StockMovementDayGroup>[];
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  String? currentLabel;
  final currentItems = <StockMovement>[];

  void flush() {
    final label = currentLabel;
    if (label == null || currentItems.isEmpty) return;
    groups.add(
      StockMovementDayGroup(
        label: label,
        movements: List.unmodifiable(currentItems),
      ),
    );
    currentItems.clear();
  }

  for (final movement in movements) {
    final local = movement.createdAt.toLocal();
    final label = _dayLabel(local, today, yesterday);
    if (label != currentLabel) {
      flush();
      currentLabel = label;
    }
    currentItems.add(movement);
  }
  flush();

  return groups;
}

String _dayLabel(DateTime date, DateTime today, DateTime yesterday) {
  if (_isSameDay(date, today)) return 'Сегодня';
  if (_isSameDay(date, yesterday)) return 'Вчера';
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}
