/// Client-side filters for the warehouse positions list.
enum StockPositionsFilter {
  all('Все'),
  lowStock('Мало'),
  zeroStock('Нулевой'),
  noAddress('Без адреса');

  const StockPositionsFilter(this.label);

  final String label;
}
