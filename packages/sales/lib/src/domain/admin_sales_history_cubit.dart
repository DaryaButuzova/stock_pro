import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:local_reference_feature/local_reference_feature.dart';

import 'models/goods_in_sale.dart';
import 'models/sale_history_entry.dart';
import 'repositories/goods_in_sales_repository.dart';
import 'repositories/sales_repository.dart';

part 'admin_sales_history_state.dart';

@injectable
class AdminSalesHistoryCubit extends Cubit<AdminSalesHistoryState> {
  AdminSalesHistoryCubit(
    this._salesRepository,
    this._goodsInSalesRepository,
    this._goodsRepository,
  ) : super(const AdminSalesHistoryInitial()) {
    loadHistory();
  }

  final SalesRepository _salesRepository;
  final GoodsInSalesRepository _goodsInSalesRepository;
  final GoodsRepository _goodsRepository;

  Future<void> loadHistory() async {
    emit(const AdminSalesHistoryLoading());
    try {
      final entries = await _salesRepository.getCompletedSales();
      emit(AdminSalesHistoryListLoaded(entries: entries));
    } catch (e) {
      emit(AdminSalesHistoryFailure(e.toString()));
    }
  }

  Future<void> openSaleDetail(SaleHistoryEntry entry) async {
    final listState = state;
    if (listState is! AdminSalesHistoryListLoaded) return;

    emit(
      AdminSalesHistoryDetailLoading(
        entries: listState.entries,
        entry: entry,
      ),
    );

    try {
      final items = await _goodsInSalesRepository.getBySaleId(entry.sale.id);
      final goodsById = <String, Goods>{};

      for (final item in items) {
        final goods = await _goodsRepository.getById(item.goodsId);
        if (goods != null) {
          goodsById[item.goodsId] = goods;
        }
      }

      emit(
        AdminSalesHistoryDetailLoaded(
          entries: listState.entries,
          entry: entry,
          items: items,
          goodsById: goodsById,
        ),
      );
    } catch (e) {
      emit(AdminSalesHistoryFailure(e.toString()));
    }
  }

  void backToList() {
    final state = this.state;
    final entries = switch (state) {
      AdminSalesHistoryDetailLoading(:final entries) => entries,
      AdminSalesHistoryDetailLoaded(:final entries) => entries,
      _ => null,
    };

    if (entries == null) return;
    emit(AdminSalesHistoryListLoaded(entries: entries));
  }
}
