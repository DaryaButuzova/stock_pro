import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/models/goods_in_sale.dart';
import '../../domain/repositories/goods_in_sales_repository.dart';

@Injectable(as: GoodsInSalesRepository)
class SupabaseGoodsInSalesRepository implements GoodsInSalesRepository {
  SupabaseGoodsInSalesRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  @override
  Future<List<GoodsInSale>> getBySaleId(String saleId) async {
    final data = await _supabaseService.client
        .from('goods_in_sales')
        .select()
        .eq('sales_id', saleId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((row) => GoodsInSale.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GoodsInSale> addOrUpdateItem({
    required String saleId,
    required String goodsId,
    required int count,
    required double cost,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final data = await _supabaseService.client
        .from('goods_in_sales')
        .upsert(
          {
            'sales_id': saleId,
            'goods_id': goodsId,
            'count': count,
            'cost': cost,
            'updated_at': now,
          },
          onConflict: 'sales_id,goods_id',
        )
        .select()
        .single();

    return GoodsInSale.fromJson(data);
  }

  @override
  Future<GoodsInSale> updateCount({
    required String itemId,
    required int count,
  }) async {
    final data = await _supabaseService.client
        .from('goods_in_sales')
        .update({
          'count': count,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', itemId)
        .select()
        .single();

    return GoodsInSale.fromJson(data);
  }

  @override
  Future<void> removeItem(String itemId) async {
    await _supabaseService.client.from('goods_in_sales').delete().eq('id', itemId);
  }
}
