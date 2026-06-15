/// Maps goods catalog errors to short Russian messages for the UI.
String mapGoodsError(Object error) {
  return _mapFromText(error.toString()) ??
      'Не удалось выполнить операцию с товаром';
}

String? _mapFromText(String text) {
  final lower = text.toLowerCase();

  if (lower.contains('admin access required')) {
    return 'Недостаточно прав';
  }
  if (lower.contains('name is required') || lower.contains('название')) {
    return 'Укажите название товара';
  }
  if (lower.contains('cost must be non-negative')) {
    return 'Цена не может быть отрицательной';
  }
  if (lower.contains('foreign key') || lower.contains('violates')) {
    return 'Товар используется в продажах или на складе и не может быть удалён';
  }
  if (lower.contains('row-level security') || lower.contains('permission')) {
    return 'Недостаточно прав';
  }

  return null;
}
