import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/models/stock_movement.dart';
import '../../domain/repositories/stock_movement_repository.dart';

@Injectable(as: StockMovementRepository)
class SupabaseStockMovementRepository implements StockMovementRepository {
  SupabaseStockMovementRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  @override
  Future<List<StockMovement>> getMovements({
    String? goodsId,
    int limit = 200,
  }) async {
    var query = _supabaseService.client
        .from('stock_movement')
        .select('*, users(creds)');

    if (goodsId != null) {
      query = query.eq('goods_id', goodsId);
    }

    final data = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List<dynamic>)
        .map((row) => StockMovement.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
