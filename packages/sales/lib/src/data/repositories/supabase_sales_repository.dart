import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/models/sale.dart';
import '../../domain/models/sale_history_entry.dart';
import '../../domain/models/sales_history_filter.dart';
import '../../domain/models/seller_option.dart';
import '../../domain/models/sale_status.dart';
import '../../domain/repositories/sales_repository.dart';

@Injectable(as: SalesRepository)
class SupabaseSalesRepository implements SalesRepository {
  SupabaseSalesRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  @override
  Future<String?> getCurrentUserId() async {
    return _supabaseService.client.auth.currentUser?.id;
  }

  @override
  Future<Sale> getOrCreateDraftSale() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      throw StateError('User is not authenticated');
    }

    final existing = await getDraftSale(userId);
    if (existing != null) {
      return existing;
    }

    final data = await _supabaseService.client
        .from('sales')
        .insert(Sale.draftInsertPayload(userId))
        .select()
        .single();

    return Sale.fromJson(data);
  }

  @override
  Future<Sale?> getDraftSale(String userId) async {
    final data = await _supabaseService.client
        .from('sales')
        .select()
        .eq('user_id', userId)
        .eq('status', SaleStatus.draft.toDbValue())
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return Sale.fromJson(data);
  }

  @override
  Future<Sale> completeSale({
    required String saleId,
    required String paymentMethod,
  }) async {
    final data = await _supabaseService.client.rpc(
      'complete_sale',
      params: {
        'p_sale_id': saleId,
        'p_payment_method': paymentMethod,
      },
    );

    return Sale.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDraftSale(String saleId) async {
    await _supabaseService.client
        .from('sales')
        .delete()
        .eq('id', saleId)
        .eq('status', SaleStatus.draft.toDbValue());
  }

  @override
  Future<List<SaleHistoryEntry>> getCompletedSales({
    SalesHistoryFilter filter = SalesHistoryFilter.empty,
  }) async {
    var query = _supabaseService.client
        .from('sales')
        .select('*, users(creds)')
        .eq('status', SaleStatus.completed.toDbValue());

    if (filter.userId != null) {
      query = query.eq('user_id', filter.userId!);
    }
    if (filter.fromDate != null) {
      final from = DateTime(
        filter.fromDate!.year,
        filter.fromDate!.month,
        filter.fromDate!.day,
      );
      query = query.gte('completed_at', from.toUtc().toIso8601String());
    }
    if (filter.toDate != null) {
      final to = DateTime(
        filter.toDate!.year,
        filter.toDate!.month,
        filter.toDate!.day,
        23,
        59,
        59,
        999,
      );
      query = query.lte('completed_at', to.toUtc().toIso8601String());
    }

    final data = await query.order('completed_at', ascending: false);

    return (data as List<dynamic>)
        .map(
          (row) => SaleHistoryEntry.fromJson(row as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<SellerOption>> getSellerOptions() async {
    final data = await _supabaseService.client
        .from('users')
        .select('id, creds')
        .order('creds', ascending: true);

    return (data as List<dynamic>)
        .map((row) => SellerOption.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
