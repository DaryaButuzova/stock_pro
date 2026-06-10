// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:local_reference_feature/local_reference_feature.dart' as _i804;
import 'package:sales_feature/src/data/repositories/supabase_goods_in_sales_repository.dart'
    as _i70;
import 'package:sales_feature/src/data/repositories/supabase_sales_repository.dart'
    as _i95;
import 'package:sales_feature/src/domain/repositories/goods_in_sales_repository.dart'
    as _i648;
import 'package:sales_feature/src/domain/repositories/sales_repository.dart'
    as _i217;
import 'package:sales_feature/src/domain/sales_cubit.dart' as _i925;
import 'package:stock_feature/stock_feature.dart' as _i922;
import 'package:supabase_feature/supabase_feature.dart' as _i375;

class SalesFeaturePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i648.GoodsInSalesRepository>(
        () => _i70.SupabaseGoodsInSalesRepository(gh<_i375.SupabaseService>()));
    gh.factory<_i217.SalesRepository>(
        () => _i95.SupabaseSalesRepository(gh<_i375.SupabaseService>()));
    gh.factory<_i925.SalesCubit>(() => _i925.SalesCubit(
          gh<_i217.SalesRepository>(),
          gh<_i648.GoodsInSalesRepository>(),
          gh<_i804.GoodsRepository>(),
          gh<_i922.StockRepository>(),
          gh<_i804.ReferenceSyncService>(),
        ));
  }
}
