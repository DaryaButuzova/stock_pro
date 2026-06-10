import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/models/stock_item.dart';
import '../../domain/repositories/stock_repository.dart';

@Injectable(as: StockRepository)
class SupabaseStockRepository implements StockRepository {
  SupabaseStockRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  @override
  Future<List<StockItem>> getStockItems() async {
    final data = await _supabaseService.client
        .from('stock')
        .select()
        .order('goods_addr', ascending: true);

    return (data as List<dynamic>)
        .map((item) => StockItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
