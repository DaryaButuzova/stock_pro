import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/repositories/goods_sync_repository.dart';
import '../database/app_database.dart';

@Injectable(as: GoodsSyncRepository)
class SupabaseGoodsSyncRepository implements GoodsSyncRepository {
  SupabaseGoodsSyncRepository(this._supabaseService, this._database);

  final SupabaseService _supabaseService;
  final AppDatabase _database;

  @override
  Future<void> syncAll() async {
    final data = await _supabaseService.client.from('goods').select();

    final rows = (data as List<dynamic>).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return;

    await _database.batch((batch) {
      for (final row in rows) {
        batch.insert(
          _database.goodsTable,
          _rowToCompanion(row),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  @override
  Future<void> applyRealtimeChange(PostgresChangePayload payload) async {
    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
      case PostgresChangeEvent.update:
        if (payload.newRecord.isEmpty) return;
        await _database.into(_database.goodsTable).insert(
          _rowToCompanion(payload.newRecord),
          mode: InsertMode.insertOrReplace,
        );
      case PostgresChangeEvent.delete:
        final id = payload.oldRecord['id'] as String?;
        if (id == null) return;
        await (_database.delete(_database.goodsTable)
              ..where((t) => t.id.equals(id)))
            .go();
      case PostgresChangeEvent.all:
        break;
    }
  }

  GoodsTableCompanion _rowToCompanion(Map<String, dynamic> row) {
    return GoodsTableCompanion.insert(
      id: row['id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      name: Value(row['name'] as String?),
      description: Value(row['description'] as String?),
      cost: Value((row['cost'] as num?)?.toDouble()),
      category: Value(row['category'] as String?),
    );
  }
}
