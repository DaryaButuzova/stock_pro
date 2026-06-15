import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:local_reference_feature/local_reference_feature.dart';

import 'models/stock_movement.dart';
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

  Future<void> loadMovements({String? goodsId}) async {
    emit(StockMovementHistoryLoading(filterGoodsId: goodsId));
    try {
      final movements = await _movementRepository.getMovements(
        goodsId: goodsId,
      );
      final goodsById = <String, Goods>{};

      for (final movement in movements) {
        if (goodsById.containsKey(movement.goodsId)) continue;
        final goods = await _goodsRepository.getById(movement.goodsId);
        if (goods != null) {
          goodsById[movement.goodsId] = goods;
        }
      }

      emit(
        StockMovementHistoryLoaded(
          movements: movements,
          goodsById: goodsById,
          filterGoodsId: goodsId,
        ),
      );
    } catch (e) {
      emit(StockMovementHistoryFailure(mapStockError(e)));
    }
  }
}
