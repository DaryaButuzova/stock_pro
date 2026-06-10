part of 'admin_sales_history_cubit.dart';

sealed class AdminSalesHistoryState extends Equatable {
  const AdminSalesHistoryState();

  @override
  List<Object?> get props => [];
}

final class AdminSalesHistoryInitial extends AdminSalesHistoryState {
  const AdminSalesHistoryInitial();
}

final class AdminSalesHistoryLoading extends AdminSalesHistoryState {
  const AdminSalesHistoryLoading();
}

final class AdminSalesHistoryListLoaded extends AdminSalesHistoryState {
  const AdminSalesHistoryListLoaded({required this.entries});

  final List<SaleHistoryEntry> entries;

  @override
  List<Object?> get props => [entries];
}

final class AdminSalesHistoryDetailLoading extends AdminSalesHistoryState {
  const AdminSalesHistoryDetailLoading({
    required this.entries,
    required this.entry,
  });

  final List<SaleHistoryEntry> entries;
  final SaleHistoryEntry entry;

  @override
  List<Object?> get props => [entries, entry];
}

final class AdminSalesHistoryDetailLoaded extends AdminSalesHistoryState {
  const AdminSalesHistoryDetailLoaded({
    required this.entries,
    required this.entry,
    required this.items,
    required this.goodsById,
  });

  final List<SaleHistoryEntry> entries;
  final SaleHistoryEntry entry;
  final List<GoodsInSale> items;
  final Map<String, Goods> goodsById;

  @override
  List<Object?> get props => [entries, entry, items, goodsById];
}

final class AdminSalesHistoryFailure extends AdminSalesHistoryState {
  const AdminSalesHistoryFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
