import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'goods_error_messages.dart';
import 'models/goods.dart';
import 'reference_sync_service.dart';
import 'repositories/goods_admin_repository.dart';
import 'repositories/goods_repository.dart';

part 'admin_goods_state.dart';

@injectable
class AdminGoodsCubit extends Cubit<AdminGoodsState> {
  AdminGoodsCubit(
    this._goodsRepository,
    this._goodsAdminRepository,
    this._referenceSyncService,
  ) : super(const AdminGoodsInitial()) {
    loadGoods();
  }

  final GoodsRepository _goodsRepository;
  final GoodsAdminRepository _goodsAdminRepository;
  final ReferenceSyncService _referenceSyncService;

  Future<void> loadGoods() async {
    emit(const AdminGoodsLoading());
    try {
      await _referenceSyncService.syncAll();
      final items = await _goodsRepository.getAll();
      emit(AdminGoodsLoaded(items: items));
    } catch (e) {
      emit(AdminGoodsFailure(mapGoodsError(e)));
    }
  }

  /// Returns an error message on failure.
  Future<String?> createGoods({
    required String name,
    String? description,
    double? cost,
    String? category,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return 'Укажите название товара';
    if (cost != null && cost < 0) return 'Цена не может быть отрицательной';

    try {
      await _goodsAdminRepository.create(
        name: trimmedName,
        description: _trimOrNull(description),
        cost: cost,
        category: _trimOrNull(category),
      );
      await loadGoods();
      return null;
    } catch (e) {
      return mapGoodsError(e);
    }
  }

  /// Returns an error message on failure.
  Future<String?> updateGoods({
    required String id,
    required String name,
    String? description,
    double? cost,
    String? category,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return 'Укажите название товара';
    if (cost != null && cost < 0) return 'Цена не может быть отрицательной';

    try {
      await _goodsAdminRepository.update(
        id: id,
        name: trimmedName,
        description: _trimOrNull(description),
        cost: cost,
        category: _trimOrNull(category),
      );
      await loadGoods();
      return null;
    } catch (e) {
      return mapGoodsError(e);
    }
  }

  /// Returns an error message on failure.
  Future<String?> deleteGoods(String id) async {
    try {
      await _goodsAdminRepository.delete(id);
      await loadGoods();
      return null;
    } catch (e) {
      return mapGoodsError(e);
    }
  }

  String? _trimOrNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
