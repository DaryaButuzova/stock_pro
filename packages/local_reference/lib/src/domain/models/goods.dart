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

  /// Parses a Supabase `goods` row.
  factory Goods.fromRow(Map<String, dynamic> row) {
    return Goods(
      id: row['id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      name: row['name'] as String?,
      description: row['description'] as String?,
      cost: (row['cost'] as num?)?.toDouble(),
      category: row['category'] as String?,
    );
  }

  /// Display label: name if present, otherwise shortened id.
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }
}
