import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:local_reference_feature/local_reference_feature.dart';

import 'models/goods_in_sale.dart';
import 'models/sale_history_entry.dart';
import 'models/sales_dashboard_metrics.dart';
import 'models/sales_history_filter.dart';
import 'models/sales_history_summary.dart';
import 'models/seller_option.dart';
import 'repositories/goods_in_sales_repository.dart';
import 'repositories/sales_repository.dart';
import 'sales_history_export.dart';

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

  SalesHistoryFilter _filter = SalesHistoryFilter.empty;
  List<SellerOption> _sellers = const [];
  List<SaleHistoryEntry> _entries = const [];

  Future<void> loadHistory({SalesHistoryFilter? filter}) async {
    if (filter != null) {
      _filter = filter;
    }

    emit(const AdminSalesHistoryLoading());
    try {
      if (_sellers.isEmpty) {
        _sellers = await _salesRepository.getSellerOptions();
      }

      _entries = await _salesRepository.getCompletedSales(filter: _filter);
      emit(_dashboardState());
    } catch (e) {
      emit(AdminSalesHistoryFailure(e.toString()));
    }
  }

  Future<void> applyFilter(SalesHistoryFilter filter) {
    return loadHistory(filter: filter);
  }

  Future<void> clearFilter() {
    return loadHistory(filter: SalesHistoryFilter.empty);
  }

  void openEntriesList() {
    emit(
      AdminSalesHistoryEntriesLoaded(
        entries: _entries,
        filter: _filter,
        sellers: _sellers,
      ),
    );
  }

  void backToDashboard() {
    emit(_dashboardState());
  }

  String? buildExportCsv() {
    final entries = switch (state) {
      AdminSalesHistoryDashboardLoaded(:final entries) => entries,
      AdminSalesHistoryEntriesLoaded(:final entries) => entries,
      _ => null,
    };
    if (entries == null) return null;

    return buildSalesHistoryCsv(
      entries: entries,
      filter: _filter,
      sellers: _sellers,
      summary: SalesHistorySummary.fromEntries(entries),
    );
  }

  Future<void> openSaleDetail(SaleHistoryEntry entry) async {
    if (state is! AdminSalesHistoryEntriesLoaded) return;

    emit(
      AdminSalesHistoryDetailLoading(
        entries: _entries,
        entry: entry,
        filter: _filter,
        sellers: _sellers,
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
          entries: _entries,
          entry: entry,
          items: items,
          goodsById: goodsById,
          filter: _filter,
          sellers: _sellers,
        ),
      );
    } catch (e) {
      emit(AdminSalesHistoryFailure(e.toString()));
    }
  }

  void backToList() {
    emit(
      AdminSalesHistoryEntriesLoaded(
        entries: _entries,
        filter: _filter,
        sellers: _sellers,
      ),
    );
  }

  AdminSalesHistoryDashboardLoaded _dashboardState() {
    return AdminSalesHistoryDashboardLoaded(
      entries: _entries,
      filter: _filter,
      sellers: _sellers,
    );
  }
}
