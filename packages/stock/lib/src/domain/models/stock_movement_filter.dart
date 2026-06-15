/// Filters for the stock movement journal.
enum StockMovementTypeFilter {
  all('Все'),
  replenishment('Пополнение'),
  writeOff('Списание'),
  sale('Продажа');

  const StockMovementTypeFilter(this.label);

  final String label;

  String? get movementType => switch (this) {
    StockMovementTypeFilter.all => null,
    StockMovementTypeFilter.replenishment => 'replenishment_in',
    StockMovementTypeFilter.writeOff => 'write_off',
    StockMovementTypeFilter.sale => 'sale_out',
  };
}
