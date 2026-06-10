/// Cart line item from `public.goods_in_sales`.
class GoodsInSale {
  const GoodsInSale({
    required this.id,
    required this.salesId,
    required this.goodsId,
    required this.count,
    required this.cost,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String salesId;
  final String goodsId;
  final int count;
  final double cost;
  final DateTime createdAt;
  final DateTime? updatedAt;

  double get lineTotal => cost * count;

  factory GoodsInSale.fromJson(Map<String, dynamic> json) {
    return GoodsInSale(
      id: json['id'] as String,
      salesId: json['sales_id'] as String,
      goodsId: json['goods_id'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }
}
