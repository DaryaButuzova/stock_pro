import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/models/goods.dart';
import '../../domain/repositories/goods_admin_repository.dart';

@Injectable(as: GoodsAdminRepository)
class SupabaseGoodsAdminRepository implements GoodsAdminRepository {
  SupabaseGoodsAdminRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  @override
  Future<Goods> create({
    required String name,
    String? description,
    double? cost,
    String? category,
  }) async {
    final data = await _supabaseService.client.rpc(
      'create_goods',
      params: {
        'p_name': name,
        'p_description': description,
        'p_cost': cost,
        'p_category': category,
      },
    );

    return Goods.fromRow(data as Map<String, dynamic>);
  }

  @override
  Future<Goods> update({
    required String id,
    required String name,
    String? description,
    double? cost,
    String? category,
  }) async {
    final data = await _supabaseService.client
        .from('goods')
        .update({
          'name': name,
          'description': description,
          'cost': cost,
          'category': category,
        })
        .eq('id', id)
        .select()
        .single();

    return Goods.fromRow(data);
  }

  @override
  Future<void> delete(String id) async {
    await _supabaseService.client.from('goods').delete().eq('id', id);
  }
}
