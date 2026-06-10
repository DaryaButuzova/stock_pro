import 'sale_status.dart';

/// Sale document from `public.sales`.
///
/// Draft sales act as the active shopping cart for a user.
class Sale {
  const Sale({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.sum,
    this.paymentMethod,
    this.completedAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final SaleStatus status;
  final DateTime createdAt;
  final double? sum;

  final String? paymentMethod;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  bool get isDraft => status == SaleStatus.draft;

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: SaleStatus.fromDbValue(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      sum: (json['sum'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String?,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> draftInsertPayload(String userId) {
    return {
      'user_id': userId,
      'status': SaleStatus.draft.toDbValue(),
    };
  }
}
