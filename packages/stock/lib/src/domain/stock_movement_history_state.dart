part of 'stock_movement_history_cubit.dart';

sealed class StockMovementHistoryState extends Equatable {
  const StockMovementHistoryState();

  @override
  List<Object?> get props => [];
}

final class StockMovementHistoryInitial extends StockMovementHistoryState {
  const StockMovementHistoryInitial();
}

final class StockMovementHistoryLoading extends StockMovementHistoryState {
  const StockMovementHistoryLoading({this.filterGoodsId});

  final String? filterGoodsId;

  @override
  List<Object?> get props => [filterGoodsId];
}

final class StockMovementHistoryLoaded extends StockMovementHistoryState {
  const StockMovementHistoryLoaded({
    required this.movements,
    required this.goodsById,
    this.filterGoodsId,
  });

  final List<StockMovement> movements;
  final Map<String, Goods> goodsById;
  final String? filterGoodsId;

  @override
  List<Object?> get props => [movements, goodsById, filterGoodsId];
}

final class StockMovementHistoryFailure extends StockMovementHistoryState {
  const StockMovementHistoryFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
