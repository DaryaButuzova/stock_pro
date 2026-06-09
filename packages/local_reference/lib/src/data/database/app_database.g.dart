// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GoodsTableTable extends GoodsTable
    with TableInfo<$GoodsTableTable, GoodsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoodsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    name,
    description,
    cost,
    category,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goods_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoodsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoodsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoodsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
    );
  }

  @override
  $GoodsTableTable createAlias(String alias) {
    return $GoodsTableTable(attachedDatabase, alias);
  }
}

class GoodsTableData extends DataClass implements Insertable<GoodsTableData> {
  final String id;
  final DateTime createdAt;
  final String? name;
  final String? description;
  final double? cost;
  final String? category;
  const GoodsTableData({
    required this.id,
    required this.createdAt,
    this.name,
    this.description,
    this.cost,
    this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || cost != null) {
      map['cost'] = Variable<double>(cost);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    return map;
  }

  GoodsTableCompanion toCompanion(bool nullToAbsent) {
    return GoodsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      cost: cost == null && nullToAbsent ? const Value.absent() : Value(cost),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
    );
  }

  factory GoodsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoodsTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String?>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      cost: serializer.fromJson<double?>(json['cost']),
      category: serializer.fromJson<String?>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String?>(name),
      'description': serializer.toJson<String?>(description),
      'cost': serializer.toJson<double?>(cost),
      'category': serializer.toJson<String?>(category),
    };
  }

  GoodsTableData copyWith({
    String? id,
    DateTime? createdAt,
    Value<String?> name = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> cost = const Value.absent(),
    Value<String?> category = const Value.absent(),
  }) => GoodsTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name.present ? name.value : this.name,
    description: description.present ? description.value : this.description,
    cost: cost.present ? cost.value : this.cost,
    category: category.present ? category.value : this.category,
  );
  GoodsTableData copyWithCompanion(GoodsTableCompanion data) {
    return GoodsTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      cost: data.cost.present ? data.cost.value : this.cost,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoodsTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('cost: $cost, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, name, description, cost, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoodsTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.description == this.description &&
          other.cost == this.cost &&
          other.category == this.category);
}

class GoodsTableCompanion extends UpdateCompanion<GoodsTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String?> name;
  final Value<String?> description;
  final Value<double?> cost;
  final Value<String?> category;
  final Value<int> rowid;
  const GoodsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.cost = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoodsTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.cost = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt);
  static Insertable<GoodsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? cost,
    Expression<String>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (cost != null) 'cost': cost,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoodsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String?>? name,
    Value<String?>? description,
    Value<double?>? cost,
    Value<String?>? category,
    Value<int>? rowid,
  }) {
    return GoodsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoodsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('cost: $cost, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GoodsTableTable goodsTable = $GoodsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [goodsTable];
}

typedef $$GoodsTableTableCreateCompanionBuilder =
    GoodsTableCompanion Function({
      required String id,
      required DateTime createdAt,
      Value<String?> name,
      Value<String?> description,
      Value<double?> cost,
      Value<String?> category,
      Value<int> rowid,
    });
typedef $$GoodsTableTableUpdateCompanionBuilder =
    GoodsTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String?> name,
      Value<String?> description,
      Value<double?> cost,
      Value<String?> category,
      Value<int> rowid,
    });

class $$GoodsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GoodsTableTable> {
  $$GoodsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoodsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GoodsTableTable> {
  $$GoodsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoodsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoodsTableTable> {
  $$GoodsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$GoodsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoodsTableTable,
          GoodsTableData,
          $$GoodsTableTableFilterComposer,
          $$GoodsTableTableOrderingComposer,
          $$GoodsTableTableAnnotationComposer,
          $$GoodsTableTableCreateCompanionBuilder,
          $$GoodsTableTableUpdateCompanionBuilder,
          (
            GoodsTableData,
            BaseReferences<_$AppDatabase, $GoodsTableTable, GoodsTableData>,
          ),
          GoodsTableData,
          PrefetchHooks Function()
        > {
  $$GoodsTableTableTableManager(_$AppDatabase db, $GoodsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoodsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoodsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoodsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoodsTableCompanion(
                id: id,
                createdAt: createdAt,
                name: name,
                description: description,
                cost: cost,
                category: category,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                Value<String?> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoodsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                name: name,
                description: description,
                cost: cost,
                category: category,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoodsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoodsTableTable,
      GoodsTableData,
      $$GoodsTableTableFilterComposer,
      $$GoodsTableTableOrderingComposer,
      $$GoodsTableTableAnnotationComposer,
      $$GoodsTableTableCreateCompanionBuilder,
      $$GoodsTableTableUpdateCompanionBuilder,
      (
        GoodsTableData,
        BaseReferences<_$AppDatabase, $GoodsTableTable, GoodsTableData>,
      ),
      GoodsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GoodsTableTableTableManager get goodsTable =>
      $$GoodsTableTableTableManager(_db, _db.goodsTable);
}
