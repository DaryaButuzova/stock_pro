/// Warehouse stock record from `public.stock`.
class StockItem {
  const StockItem({
    required this.goodsId,
    required this.goodsAddr,
    required this.count,
    required this.minCount,
    required this.createdAt,
  });

  /// Primary key — goods identifier.
  final String goodsId;
  final String goodsAddr;
  final int count;
  final int minCount;
  final DateTime createdAt;

  /// Whether current quantity is at or below minimum threshold.
  bool get isLowStock => count <= minCount;

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      goodsId: json['goods_id'] as String,
      goodsAddr: json['goods_addr'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      minCount: json['min_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
