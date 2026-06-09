import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/models/goods.dart';
import '../../domain/repositories/goods_repository.dart';
import '../database/app_database.dart';

@Injectable(as: GoodsRepository)
class DriftGoodsRepository implements GoodsRepository {
  DriftGoodsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Goods>> getAll() async {
    final rows = await (_database.select(_database.goodsTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();

    return rows.map(_toDomain).toList();
  }

  @override
  Future<Goods?> getById(String id) async {
    final row = await (_database.select(_database.goodsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    return row == null ? null : _toDomain(row);
  }

  Goods _toDomain(GoodsTableData row) {
    return Goods(
      id: row.id,
      createdAt: row.createdAt,
      name: row.name,
      description: row.description,
      cost: row.cost,
      category: row.category,
    );
  }
}
