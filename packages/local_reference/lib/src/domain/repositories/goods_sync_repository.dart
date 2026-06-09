import 'package:supabase_feature/supabase_feature.dart';

/// Remote sync for the goods reference table.
abstract class GoodsSyncRepository {
  /// Fetches goods from Supabase and upserts them into local storage.
  Future<void> syncAll();

  /// Applies a single realtime change to local storage.
  Future<void> applyRealtimeChange(PostgresChangePayload payload);
}
