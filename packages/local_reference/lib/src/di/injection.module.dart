// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:local_reference_feature/src/data/database/app_database.dart'
    as _i553;
import 'package:local_reference_feature/src/data/repositories/drift_goods_repository.dart'
    as _i36;
import 'package:local_reference_feature/src/data/repositories/supabase_goods_sync_repository.dart'
    as _i209;
import 'package:local_reference_feature/src/di/injection.dart' as _i218;
import 'package:local_reference_feature/src/domain/goods_realtime_service.dart'
    as _i271;
import 'package:local_reference_feature/src/domain/reference_sync_service.dart'
    as _i15;
import 'package:local_reference_feature/src/domain/repositories/goods_repository.dart'
    as _i387;
import 'package:local_reference_feature/src/domain/repositories/goods_sync_repository.dart'
    as _i662;
import 'package:supabase_feature/supabase_feature.dart' as _i375;

class LocalReferenceFeaturePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final localReferenceDatabaseModule = _$LocalReferenceDatabaseModule();
    gh.lazySingleton<_i553.AppDatabase>(
        () => localReferenceDatabaseModule.appDatabase());
    gh.factory<_i387.GoodsRepository>(
        () => _i36.DriftGoodsRepository(gh<_i553.AppDatabase>()));
    gh.factory<_i662.GoodsSyncRepository>(
        () => _i209.SupabaseGoodsSyncRepository(
              gh<_i375.SupabaseService>(),
              gh<_i553.AppDatabase>(),
            ));
    gh.lazySingleton<_i15.ReferenceSyncService>(
        () => _i15.ReferenceSyncService(gh<_i662.GoodsSyncRepository>()));
    gh.lazySingleton<_i271.GoodsRealtimeService>(
        () => _i271.GoodsRealtimeService(
              gh<_i375.SupabaseService>(),
              gh<_i662.GoodsSyncRepository>(),
            ));
  }
}

class _$LocalReferenceDatabaseModule
    extends _i218.LocalReferenceDatabaseModule {}
