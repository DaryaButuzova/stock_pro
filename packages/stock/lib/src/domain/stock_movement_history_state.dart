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
  const StockMovementHistoryLoading({
    this.filterGoodsId,
    this.typeFilter = StockMovementTypeFilter.all,
  });

  final String? filterGoodsId;
  final StockMovementTypeFilter typeFilter;

  @override
  List<Object?> get props => [filterGoodsId, typeFilter];
}

final class StockMovementHistoryLoaded extends StockMovementHistoryState {
  const StockMovementHistoryLoaded({
    required this.movements,
    required this.goodsById,
    this.filterGoodsId,
    this.typeFilter = StockMovementTypeFilter.all,
  });

  final List<StockMovement> movements;
  final Map<String, Goods> goodsById;
  final String? filterGoodsId;
  final StockMovementTypeFilter typeFilter;

  List<StockMovement> get visibleMovements {
    final type = typeFilter.movementType;
    if (type == null) return movements;
    return movements.where((m) => m.movementType == type).toList();
  }

  StockMovementSummary get summary =>
      StockMovementSummary.fromMovements(visibleMovements);

  List<StockMovementDayGroup> get dayGroups =>
      groupMovementsByDay(visibleMovements);

  @override
  List<Object?> get props => [movements, goodsById, filterGoodsId, typeFilter];
}

final class StockMovementHistoryFailure extends StockMovementHistoryState {
  const StockMovementHistoryFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
