import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:supabase_feature/supabase_feature.dart';

import 'models/stock_dashboard_metrics.dart';
import 'models/stock_item.dart';
import 'models/stock_positions_filter.dart';
import 'repositories/stock_repository.dart';
import 'stock_error_messages.dart';
import 'stock_list_utils.dart';

part 'admin_stock_state.dart';

@injectable
class AdminStockCubit extends Cubit<AdminStockState> {
  AdminStockCubit(
    this._stockRepository,
    this._goodsRepository,
    this._referenceSyncService,
    this._supabaseService,
  ) : super(const AdminStockInitial()) {
    loadStock();
    _subscribeToStockChanges();
  }

  final StockRepository _stockRepository;
  final GoodsRepository _goodsRepository;
  final ReferenceSyncService _referenceSyncService;
  final SupabaseService _supabaseService;

  RealtimeChannel? _stockChannel;
  List<StockItem> _items = const [];
  Map<String, Goods> _goodsById = const {};
  StockPositionsFilter _listFilter = StockPositionsFilter.all;
  String _searchQuery = '';

  void _subscribeToStockChanges() {
    _stockChannel = _supabaseService.client
        .channel('admin-stock-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock',
          callback: (_) => unawaited(loadStock(silent: true)),
        )
        .subscribe();
  }

  Future<void> loadStock({bool silent = false}) async {
    if (!silent) emit(const AdminStockLoading());
    try {
      if (!silent) {
        await _referenceSyncService.syncAll();
      }

      _items = await _stockRepository.getStockItems();
      _goodsById = <String, Goods>{};
      for (final item in _items) {
        final goods = await _goodsRepository.getById(item.goodsId);
        if (goods != null) {
          _goodsById[item.goodsId] = goods;
        }
      }

      emit(_restoreViewState());
    } catch (e) {
      if (!silent) {
        emit(AdminStockFailure(mapStockError(e)));
      }
    }
  }

  void openPositionsList({
    StockPositionsFilter filter = StockPositionsFilter.all,
    String searchQuery = '',
  }) {
    _listFilter = filter;
    _searchQuery = searchQuery;
    emit(
      AdminStockPositionsLoaded(
        items: _items,
        goodsById: _goodsById,
        filter: _listFilter,
        searchQuery: _searchQuery,
      ),
    );
  }

  void applyListFilter(StockPositionsFilter filter) {
    _listFilter = filter;
    emit(
      AdminStockPositionsLoaded(
        items: _items,
        goodsById: _goodsById,
        filter: _listFilter,
        searchQuery: _searchQuery,
      ),
    );
  }

  void applySearchQuery(String query) {
    _searchQuery = query;
    final state = this.state;
    if (state is AdminStockPositionsLoaded) {
      emit(
        AdminStockPositionsLoaded(
          items: _items,
          goodsById: _goodsById,
          filter: _listFilter,
          searchQuery: _searchQuery,
        ),
      );
    }
  }

  void openPositionDetail(StockItem item) {
    emit(
      AdminStockPositionDetailLoaded(
        items: _items,
        goodsById: _goodsById,
        item: item,
        listFilter: _listFilter,
        searchQuery: _searchQuery,
      ),
    );
  }

  void backToDashboard() {
    emit(_dashboardState());
  }

  void backToList() {
    emit(
      AdminStockPositionsLoaded(
        items: _items,
        goodsById: _goodsById,
        filter: _listFilter,
        searchQuery: _searchQuery,
      ),
    );
  }

  Future<String?> replenishStock({
    required String goodsId,
    required int count,
    String? comment,
  }) async {
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
      return mapStockError(e);
    }
  }

  Future<String?> writeOffStock({
    required String goodsId,
    required int count,
    String? comment,
  }) async {
    if (count <= 0) return 'Количество должно быть больше нуля';

    final item = _items.where((entry) => entry.goodsId == goodsId).firstOrNull;
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
      return mapStockError(e);
    }
  }

  Future<String?> updateStockMeta({
    required String goodsId,
    required String goodsAddr,
    required int minCount,
  }) async {
    if (minCount < 0) return 'Минимальный остаток не может быть отрицательным';

    try {
      await _stockRepository.updateStockMeta(
        goodsId: goodsId,
        goodsAddr: goodsAddr.trim(),
        minCount: minCount,
      );
      await loadStock(silent: true);
      return null;
    } catch (e) {
      return mapStockError(e);
    }
  }

  Future<String?> deleteStockPosition(String goodsId) async {
    final item = _items.where((entry) => entry.goodsId == goodsId).firstOrNull;
    if (item != null && item.count != 0) {
      return 'Удаление возможно только при нулевом остатке';
    }

    try {
      await _stockRepository.deleteStockPosition(goodsId);
      await loadStock(silent: true);
      return null;
    } catch (e) {
      return mapStockError(e);
    }
  }

  AdminStockState _restoreViewState() {
    return switch (state) {
      AdminStockPositionsLoaded() => AdminStockPositionsLoaded(
        items: _items,
        goodsById: _goodsById,
        filter: _listFilter,
        searchQuery: _searchQuery,
      ),
      AdminStockPositionDetailLoaded(:final item) =>
        AdminStockPositionDetailLoaded(
          items: _items,
          goodsById: _goodsById,
          item: _items.firstWhere(
            (entry) => entry.goodsId == item.goodsId,
            orElse: () => item,
          ),
          listFilter: _listFilter,
          searchQuery: _searchQuery,
        ),
      _ => _dashboardState(),
    };
  }

  AdminStockDashboardLoaded _dashboardState() {
    return AdminStockDashboardLoaded(
      items: _items,
      goodsById: _goodsById,
    );
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
