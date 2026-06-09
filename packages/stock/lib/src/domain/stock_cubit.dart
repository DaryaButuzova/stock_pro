import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:supabase_feature/supabase_feature.dart';

import 'models/stock_item.dart';
import 'repositories/stock_repository.dart';

part 'stock_state.dart';

@injectable
class StockCubit extends Cubit<StockState> {
  StockCubit(
    this._stockRepository,
    this._goodsRepository,
    this._referenceSyncService,
    this._supabaseService,
  ) : super(StockInitial()) {
    loadStock();
    _subscribeToStockChanges();
  }

  final StockRepository _stockRepository;
  final GoodsRepository _goodsRepository;
  final ReferenceSyncService _referenceSyncService;
  final SupabaseService _supabaseService;

  RealtimeChannel? _stockChannel;

  void _subscribeToStockChanges() {
    _stockChannel = _supabaseService.client
        .channel('stock-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock',
          callback: (_) => unawaited(loadStock(silent: true)),
        )
        .subscribe();
  }

  Future<void> loadStock({bool silent = false}) async {
    if (!silent) emit(StockLoading());
    try {
      if (!silent) {
        await _referenceSyncService.syncAll();
      }

      final items = await _stockRepository.getStockItems();
      final goodsById = <String, Goods>{};

      for (final item in items) {
        final goods = await _goodsRepository.getById(item.goodsId);
        if (goods != null) {
          goodsById[item.goodsId] = goods;
        }
      }

      emit(StockLoaded(items: items, goodsById: goodsById));
    } catch (e) {
      if (!silent) {
        emit(StockFailure(e.toString()));
      }
    }
  }

  @override
  Future<void> close() async {
    final channel = _stockChannel;
    _stockChannel = null;
    if (channel != null) {
      await _supabaseService.client.removeChannel(channel);
    }
    return super.close();
  }
}
