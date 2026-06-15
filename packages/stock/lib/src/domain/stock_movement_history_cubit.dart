import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:local_reference_feature/local_reference_feature.dart';

import 'models/stock_movement.dart';
import 'models/stock_movement_filter.dart';
import 'models/stock_movement_summary.dart';
import 'repositories/stock_movement_repository.dart';
import 'stock_error_messages.dart';

part 'stock_movement_history_state.dart';

@injectable
class StockMovementHistoryCubit extends Cubit<StockMovementHistoryState> {
  StockMovementHistoryCubit(
    this._movementRepository,
    this._goodsRepository,
  ) : super(const StockMovementHistoryInitial());

  final StockMovementRepository _movementRepository;
  final GoodsRepository _goodsRepository;

  String? _filterGoodsId;
  StockMovementTypeFilter _typeFilter = StockMovementTypeFilter.all;
  List<StockMovement> _movements = const [];
  Map<String, Goods> _goodsById = const {};

  Future<void> loadMovements({
    String? goodsId,
    StockMovementTypeFilter? typeFilter,
  }) async {
    if (goodsId != null) _filterGoodsId = goodsId;
    if (typeFilter != null) _typeFilter = typeFilter;

    emit(
      StockMovementHistoryLoading(
        filterGoodsId: _filterGoodsId,
        typeFilter: _typeFilter,
      ),
    );
    try {
      final movements = await _movementRepository.getMovements(
        goodsId: _filterGoodsId,
      );
      final goodsById = <String, Goods>{};

      for (final movement in movements) {
        if (goodsById.containsKey(movement.goodsId)) continue;
        final goods = await _goodsRepository.getById(movement.goodsId);
        if (goods != null) {
          goodsById[movement.goodsId] = goods;
        }
      }

      _movements = movements;
      _goodsById = goodsById;
      emit(_loadedState());
    } catch (e) {
      emit(StockMovementHistoryFailure(mapStockError(e)));
    }
  }

  void applyTypeFilter(StockMovementTypeFilter filter) {
    _typeFilter = filter;
    emit(_loadedState());
  }

  StockMovementHistoryLoaded _loadedState() {
    return StockMovementHistoryLoaded(
      movements: _movements,
      goodsById: _goodsById,
      filterGoodsId: _filterGoodsId,
      typeFilter: _typeFilter,
    );
  }
}
