import '../models/sale.dart';
import '../models/sale_history_entry.dart';

/// Persistence for `public.sales`.
abstract class SalesRepository {
  /// Returns the authenticated user id, or null if not signed in.
  Future<String?> getCurrentUserId();

  /// Returns the user's draft sale or creates a new one.
  Future<Sale> getOrCreateDraftSale();

  /// Returns the user's draft sale, if any.
  Future<Sale?> getDraftSale(String userId);

  /// Finalizes a draft sale: writes stock movements and deducts stock.
  Future<Sale> completeSale({
    required String saleId,
    required String paymentMethod,
  });

  /// Removes an empty draft sale. No-op if the sale is not a draft.
  Future<void> deleteDraftSale(String saleId);

  /// Returns completed sales for admin history (newest first).
  Future<List<SaleHistoryEntry>> getCompletedSales();
}
