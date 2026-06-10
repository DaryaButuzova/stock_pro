part of 'sales_cubit.dart';

sealed class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object?> get props => [];
}

final class SalesInitial extends SalesState {}

final class SalesLoading extends SalesState {}

final class SalesCartBuilding extends SalesState {
  const SalesCartBuilding({
    this.sale,
    required this.items,
    required this.goodsById,
    required this.stockByGoodsId,
    required this.catalogGoods,
  });

  /// Active draft sale, if the cart has been persisted.
  final Sale? sale;
  final List<GoodsInSale> items;
  final Map<String, Goods> goodsById;
  final Map<String, int> stockByGoodsId;
  final List<Goods> catalogGoods;

  double get total => items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  @override
  List<Object?> get props => [
    sale,
    items,
    goodsById,
    stockByGoodsId,
    catalogGoods,
  ];
}

final class SalesCheckout extends SalesState {
  const SalesCheckout({
    required this.sale,
    required this.items,
    required this.goodsById,
    required this.stockByGoodsId,
    required this.catalogGoods,
    required this.paymentMethod,
  });

  final Sale sale;
  final List<GoodsInSale> items;
  final Map<String, Goods> goodsById;
  final Map<String, int> stockByGoodsId;
  final List<Goods> catalogGoods;
  final String paymentMethod;

  double get total => items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  @override
  List<Object?> get props => [
    sale,
    items,
    goodsById,
    stockByGoodsId,
    catalogGoods,
    paymentMethod,
  ];
}

final class SalesFailure extends SalesState {
  const SalesFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
