/// Goods reference record from `public.goods`.
class Goods {
  const Goods({
    required this.id,
    required this.createdAt,
    this.name,
    this.description,
    this.cost,
    this.category,
  });

  final String id;
  final DateTime createdAt;
  final String? name;
  final String? description;
  final double? cost;
  final String? category;

  /// Display label: name if present, otherwise shortened id.
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }
}
