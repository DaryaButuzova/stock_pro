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

final class AdminSalesHistoryDashboardLoaded extends AdminSalesHistoryState {
  const AdminSalesHistoryDashboardLoaded({
    required this.entries,
    required this.filter,
    required this.sellers,
  });

  final List<SaleHistoryEntry> entries;
  final SalesHistoryFilter filter;
  final List<SellerOption> sellers;

  SalesHistorySummary get summary => SalesHistorySummary.fromEntries(entries);

  SalesDashboardMetrics get metrics =>
      SalesDashboardMetrics.fromEntries(entries);

  @override
  List<Object?> get props => [entries, filter, sellers];
}

final class AdminSalesHistoryEntriesLoaded extends AdminSalesHistoryState {
  const AdminSalesHistoryEntriesLoaded({
    required this.entries,
    required this.filter,
    required this.sellers,
  });

  final List<SaleHistoryEntry> entries;
  final SalesHistoryFilter filter;
  final List<SellerOption> sellers;

  SalesHistorySummary get summary => SalesHistorySummary.fromEntries(entries);

  @override
  List<Object?> get props => [entries, filter, sellers];
}

final class AdminSalesHistoryDetailLoading extends AdminSalesHistoryState {
  const AdminSalesHistoryDetailLoading({
    required this.entries,
    required this.entry,
    required this.filter,
    required this.sellers,
  });

  final List<SaleHistoryEntry> entries;
  final SaleHistoryEntry entry;
  final SalesHistoryFilter filter;
  final List<SellerOption> sellers;

  @override
  List<Object?> get props => [entries, entry, filter, sellers];
}

final class AdminSalesHistoryDetailLoaded extends AdminSalesHistoryState {
  const AdminSalesHistoryDetailLoaded({
    required this.entries,
    required this.entry,
    required this.items,
    required this.goodsById,
    required this.filter,
    required this.sellers,
  });

  final List<SaleHistoryEntry> entries;
  final SaleHistoryEntry entry;
  final List<GoodsInSale> items;
  final Map<String, Goods> goodsById;
  final SalesHistoryFilter filter;
  final List<SellerOption> sellers;

  @override
  List<Object?> get props => [entries, entry, items, goodsById, filter, sellers];
}

final class AdminSalesHistoryFailure extends AdminSalesHistoryState {
  const AdminSalesHistoryFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
