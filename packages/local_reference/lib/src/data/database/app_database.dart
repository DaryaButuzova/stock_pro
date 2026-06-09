import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Local cache of the `goods` reference table from Supabase.
class GoodsTable extends Table {
  TextColumn get id => text()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get name => text().nullable()();

  TextColumn get description => text().nullable()();

  RealColumn get cost => real().nullable()();

  TextColumn get category => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [GoodsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.deleteTable('goods_table');
        await migrator.createTable(goodsTable);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'reference_cache.sqlite'));
    return NativeDatabase(file);
  });
}
