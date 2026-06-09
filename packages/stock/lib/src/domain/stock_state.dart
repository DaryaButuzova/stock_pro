part of 'stock_cubit.dart';

sealed class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

final class StockInitial extends StockState {}

final class StockLoading extends StockState {}

final class StockLoaded extends StockState {
  const StockLoaded({
    required this.items,
    this.goodsById = const {},
  });

  final List<StockItem> items;
  final Map<String, Goods> goodsById;

  @override
  List<Object?> get props => [items, goodsById];
}

final class StockFailure extends StockState {
  const StockFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
