part of 'admin_stock_cubit.dart';

sealed class AdminStockState extends Equatable {
  const AdminStockState();

  @override
  List<Object?> get props => [];
}

final class AdminStockInitial extends AdminStockState {
  const AdminStockInitial();
}

final class AdminStockLoading extends AdminStockState {
  const AdminStockLoading();
}

final class AdminStockDashboardLoaded extends AdminStockState {
  const AdminStockDashboardLoaded({
    required this.items,
    required this.goodsById,
  });

  final List<StockItem> items;
  final Map<String, Goods> goodsById;

  StockDashboardMetrics get metrics => StockDashboardMetrics.fromItems(items);

  @override
  List<Object?> get props => [items, goodsById];
}

final class AdminStockPositionsLoaded extends AdminStockState {
  const AdminStockPositionsLoaded({
    required this.items,
    required this.goodsById,
    required this.filter,
    required this.searchQuery,
  });

  final List<StockItem> items;
  final Map<String, Goods> goodsById;
  final StockPositionsFilter filter;
  final String searchQuery;

  List<StockItem> get visibleItems => filterStockItems(
    items: items,
    goodsById: goodsById,
    filter: filter,
    searchQuery: searchQuery,
  );

  @override
  List<Object?> get props => [items, goodsById, filter, searchQuery];
}

final class AdminStockPositionDetailLoaded extends AdminStockState {
  const AdminStockPositionDetailLoaded({
    required this.items,
    required this.goodsById,
    required this.item,
    required this.listFilter,
    required this.searchQuery,
  });

  final List<StockItem> items;
  final Map<String, Goods> goodsById;
  final StockItem item;
  final StockPositionsFilter listFilter;
  final String searchQuery;

  @override
  List<Object?> get props => [items, goodsById, item, listFilter, searchQuery];
}

final class AdminStockFailure extends AdminStockState {
  const AdminStockFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
