/// Maps warehouse errors to short Russian messages for the UI.
String mapStockError(Object error) {
  return _mapFromText(error.toString()) ??
      'Не удалось выполнить операцию со складом';
}

String? _mapFromText(String text) {
  final lower = text.toLowerCase();

  if (lower.contains('admin access required')) {
    return 'Недостаточно прав';
  }
  if (lower.contains('stock record not found')) {
    return 'Позиция на складе не найдена';
  }
  if (lower.contains('goods not found')) {
    return 'Товар не найден';
  }
  if (lower.contains('stock position already exists')) {
    return 'Позиция на складе уже существует';
  }
  if (lower.contains('stock count must be zero')) {
    return 'Удаление возможно только при нулевом остатке';
  }
  if (lower.contains('min_count must be non-negative')) {
    return 'Минимальный остаток не может быть отрицательным';
  }
  if (lower.contains('count must be positive')) {
    return 'Количество должно быть больше нуля';
  }
  if (lower.contains('insufficient stock')) {
    return 'Недостаточно на складе';
  }

  return null;
}
