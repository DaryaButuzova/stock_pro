/// Stock movement record from `public.stock_movement`.
class StockMovement {
  const StockMovement({
    required this.id,
    required this.createdAt,
    required this.goodsId,
    required this.count,
    required this.movementType,
    this.userId,
    this.salesId,
    this.comment,
    this.actorName,
  });

  final String id;
  final DateTime createdAt;
  final String? userId;
  final String goodsId;
  final String? salesId;
  final int count;
  final String movementType;
  final String? comment;
  final String? actorName;

  /// Signed quantity change for display.
  int get signedCount => count;

  String get typeLabel => switch (movementType) {
    'sale_out' => 'Продажа',
    'replenishment_in' => 'Пополнение',
    'write_off' => 'Списание',
    _ => movementType,
  };

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    final users = json['users'];
    String? actorName;
    if (users is Map<String, dynamic>) {
      actorName = users['creds'] as String?;
    }

    return StockMovement(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String?,
      goodsId: json['goods_id'] as String,
      salesId: json['sales_id'] as String?,
      count: (json['count'] as num).toInt(),
      movementType: json['movement_type'] as String,
      comment: json['comment'] as String?,
      actorName: actorName,
    );
  }
}
