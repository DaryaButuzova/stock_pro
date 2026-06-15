// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:local_reference_feature/local_reference_feature.dart' as _i804;
import 'package:stock_feature/src/data/repositories/supabase_stock_movement_repository.dart'
    as _i60;
import 'package:stock_feature/src/data/repositories/supabase_stock_repository.dart'
    as _i211;
import 'package:stock_feature/src/domain/repositories/stock_movement_repository.dart'
    as _i110;
import 'package:stock_feature/src/domain/repositories/stock_repository.dart'
    as _i99;
import 'package:stock_feature/src/domain/stock_cubit.dart' as _i190;
import 'package:stock_feature/src/domain/stock_movement_history_cubit.dart'
    as _i924;
import 'package:supabase_feature/supabase_feature.dart' as _i375;

class StockFeaturePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i110.StockMovementRepository>(() =>
        _i60.SupabaseStockMovementRepository(gh<_i375.SupabaseService>()));
    gh.factory<_i99.StockRepository>(
        () => _i211.SupabaseStockRepository(gh<_i375.SupabaseService>()));
    gh.factory<_i924.StockMovementHistoryCubit>(
        () => _i924.StockMovementHistoryCubit(
              gh<_i110.StockMovementRepository>(),
              gh<_i804.GoodsRepository>(),
            ));
    gh.factory<_i190.StockCubit>(() => _i190.StockCubit(
          gh<_i99.StockRepository>(),
          gh<_i804.GoodsRepository>(),
          gh<_i804.ReferenceSyncService>(),
          gh<_i375.SupabaseService>(),
        ));
  }
}
