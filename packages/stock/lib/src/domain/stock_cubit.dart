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

  /// Returns an error message on failure.
  Future<String?> replenishStock({
    required String goodsId,
    required int count,
    String? comment,
  }) async {
    if (this.state is! StockLoaded) return null;
    if (count <= 0) return 'Количество должно быть больше нуля';

    try {
      await _stockRepository.replenishStock(
        goodsId: goodsId,
        count: count,
        comment: comment,
      );
      await loadStock(silent: true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns an error message on failure.
  Future<String?> writeOffStock({
    required String goodsId,
    required int count,
    String? comment,
  }) async {
    final state = this.state;
    if (state is! StockLoaded) return null;
    if (count <= 0) return 'Количество должно быть больше нуля';

    final item = state.items
        .where((entry) => entry.goodsId == goodsId)
        .firstOrNull;
    final available = item?.count ?? 0;
    if (count > available) {
      return 'Недостаточно на складе (доступно: $available)';
    }

    try {
      await _stockRepository.writeOffStock(
        goodsId: goodsId,
        count: count,
        comment: comment,
      );
      await loadStock(silent: true);
      return null;
    } catch (e) {
      return e.toString();
    }
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
