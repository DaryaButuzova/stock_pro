/// Lifecycle status of a [Sale] record.
enum SaleStatus {
  /// Active cart — items can be added in `goods_in_sales`.
  draft,

  /// Sale finalized, stock movements created.
  completed,

  /// Cancelled draft or voided sale.
  cancelled;

  String toDbValue() => name;

  static SaleStatus fromDbValue(String value) {
    return SaleStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SaleStatus.draft,
    );
  }
}
