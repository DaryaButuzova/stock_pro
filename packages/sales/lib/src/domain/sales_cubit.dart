import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:stock_feature/stock_feature.dart';

import 'models/goods_in_sale.dart';
import 'models/sale.dart';
import 'repositories/goods_in_sales_repository.dart';
import 'repositories/sales_repository.dart';

part 'sales_state.dart';

/// Supported payment methods for checkout UI.
abstract final class PaymentMethods {
  static const cash = 'cash';
  static const card = 'card';

  static const labels = <String, String>{
    cash: 'Наличные',
    card: 'Карта',
  };
}

@injectable
class SalesCubit extends Cubit<SalesState> {
  SalesCubit(
    this._salesRepository,
    this._goodsInSalesRepository,
    this._goodsRepository,
    this._stockRepository,
    this._referenceSyncService,
  ) : super(SalesInitial()) {
    unawaited(loadCart());
  }

  final SalesRepository _salesRepository;
  final GoodsInSalesRepository _goodsInSalesRepository;
  final GoodsRepository _goodsRepository;
  final StockRepository _stockRepository;
  final ReferenceSyncService _referenceSyncService;

  Future<void> loadCart() async {
    if (!isClosed) emit(SalesLoading());
    try {
      final snapshot = await _loadCartSnapshot();
      if (!isClosed) emit(snapshot.toCartBuilding());
      unawaited(_syncCatalogAndRefresh());
    } catch (e, stackTrace) {
      debugPrint('SalesCubit.loadCart failed: $e\n$stackTrace');
      if (!isClosed) emit(SalesFailure(e.toString()));
    }
  }

  Future<void> _syncCatalogAndRefresh() async {
    try {
      await _referenceSyncService.syncAll();
      if (isClosed || this.state is! SalesCartBuilding) return;

      final current = this.state as SalesCartBuilding;
      emit((await _buildSnapshot(current.sale)).toCartBuilding());
    } catch (e, stackTrace) {
      debugPrint('SalesCubit._syncCatalogAndRefresh failed: $e\n$stackTrace');
    }
  }

  Future<_CartSnapshot> _loadCartSnapshot() async {
    final userId = await _salesRepository.getCurrentUserId();
    if (userId == null) {
      throw StateError('User is not authenticated');
    }

    var draft = await _salesRepository.getDraftSale(userId);
    if (draft != null) {
      final items = await _goodsInSalesRepository.getBySaleId(draft.id);
      if (items.isEmpty) {
        await _salesRepository.deleteDraftSale(draft.id);
        draft = null;
      }
    }

    return _buildSnapshot(draft);
  }

  /// Returns a validation or persistence error message, if any.
  Future<String?> addToCart({
    required String goodsId,
    required int quantity,
  }) async {
    final state = this.state;
    if (state is! SalesCartBuilding) return null;
    if (quantity <= 0) return null;

    try {
      final goods = state.goodsById[goodsId] ??
          await _goodsRepository.getById(goodsId);
      if (goods == null) {
        await loadCart();
        return 'Товар не найден';
      }

      final stockCount = state.stockByGoodsId[goodsId] ?? 0;
      final existing = state.items
          .where((item) => item.goodsId == goodsId)
          .firstOrNull;
      final newCount = (existing?.count ?? 0) + quantity;

      if (newCount > stockCount) {
        return 'Недостаточно на складе (доступно: $stockCount)';
      }

      final sale = state.sale ?? await _salesRepository.getOrCreateDraftSale();

      await _goodsInSalesRepository.addOrUpdateItem(
        saleId: sale.id,
        goodsId: goodsId,
        count: newCount,
        cost: goods.cost ?? 0,
      );

      emit((await _buildSnapshot(sale)).toCartBuilding());
      return null;
    } catch (e) {
      emit(SalesFailure(e.toString()));
      return e.toString();
    }
  }

  /// Returns a validation or persistence error message, if any.
  Future<String?> updateItemCount({
    required String itemId,
    required int count,
  }) async {
    final state = this.state;
    if (state is! SalesCartBuilding) return null;
    if (count <= 0) {
      await removeItem(itemId);
      return null;
    }

    try {
      final item = state.items.firstWhere((entry) => entry.id == itemId);
      final stockCount = state.stockByGoodsId[item.goodsId] ?? 0;
      if (count > stockCount) {
        return 'Недостаточно на складе (доступно: $stockCount)';
      }

      await _goodsInSalesRepository.updateCount(itemId: itemId, count: count);

      final sale = state.sale;
      if (sale == null) {
        await loadCart();
        return null;
      }

      emit((await _buildSnapshot(sale)).toCartBuilding());
      return null;
    } catch (e) {
      emit(SalesFailure(e.toString()));
      return e.toString();
    }
  }

  Future<void> removeItem(String itemId) async {
    final state = this.state;
    if (state is! SalesCartBuilding) return;

    try {
      await _goodsInSalesRepository.removeItem(itemId);

      final sale = state.sale;
      if (sale == null) {
        await loadCart();
        return;
      }

      final snapshot = await _buildSnapshot(sale);
      if (snapshot.items.isEmpty) {
        await _salesRepository.deleteDraftSale(sale.id);
        emit((await _buildSnapshot()).toCartBuilding());
        return;
      }

      emit(snapshot.toCartBuilding());
    } catch (e) {
      emit(SalesFailure(e.toString()));
    }
  }

  void goToCheckout() {
    final state = this.state;
    final sale = state is SalesCartBuilding ? state.sale : null;
    if (state is! SalesCartBuilding || sale == null || state.items.isEmpty) {
      return;
    }

    emit(
      SalesCheckout(
        sale: sale,
        items: state.items,
        goodsById: state.goodsById,
        stockByGoodsId: state.stockByGoodsId,
        catalogGoods: state.catalogGoods,
        paymentMethod: PaymentMethods.cash,
      ),
    );
  }

  void backToCart() {
    final state = this.state;
    if (state is! SalesCheckout) return;

    emit(
      SalesCartBuilding(
        sale: state.sale,
        items: state.items,
        goodsById: state.goodsById,
        stockByGoodsId: state.stockByGoodsId,
        catalogGoods: state.catalogGoods,
      ),
    );
  }

  void selectPaymentMethod(String method) {
    final state = this.state;
    if (state is! SalesCheckout) return;

    emit(SalesCheckout(
      sale: state.sale,
      items: state.items,
      goodsById: state.goodsById,
      stockByGoodsId: state.stockByGoodsId,
      catalogGoods: state.catalogGoods,
      paymentMethod: method,
    ));
  }

  /// Returns completed [Sale] on success, or an error message.
  Future<({Sale? sale, String? error})> confirmSale() async {
    final state = this.state;
    if (state is! SalesCheckout) {
      return (sale: null, error: null);
    }

    try {
      final completed = await _salesRepository.completeSale(
        saleId: state.sale.id,
        paymentMethod: state.paymentMethod,
      );
      await loadCart();
      return (sale: completed, error: null);
    } catch (e) {
      emit(state);
      return (sale: null, error: e.toString());
    }
  }

  Future<_CartSnapshot> _buildSnapshot([Sale? sale]) async {
    final items = sale == null
        ? const <GoodsInSale>[]
        : await _goodsInSalesRepository.getBySaleId(sale.id);
    final stockItems = await _stockRepository.getStockItems();
    final stockByGoodsId = {
      for (final item in stockItems) item.goodsId: item.count,
    };

    final catalogGoods = await _goodsRepository.getAll();
    final goodsById = {for (final goods in catalogGoods) goods.id: goods};

    return _CartSnapshot(
      sale: sale,
      items: items,
      goodsById: goodsById,
      stockByGoodsId: stockByGoodsId,
      catalogGoods: catalogGoods,
    );
  }
}

class _CartSnapshot {
  const _CartSnapshot({
    required this.sale,
    required this.items,
    required this.goodsById,
    required this.stockByGoodsId,
    required this.catalogGoods,
  });

  final Sale? sale;
  final List<GoodsInSale> items;
  final Map<String, Goods> goodsById;
  final Map<String, int> stockByGoodsId;
  final List<Goods> catalogGoods;

  SalesCartBuilding toCartBuilding() {
    return SalesCartBuilding(
      sale: sale,
      items: items,
      goodsById: goodsById,
      stockByGoodsId: stockByGoodsId,
      catalogGoods: catalogGoods,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
