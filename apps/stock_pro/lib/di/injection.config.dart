// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:authorization_feature/authorization_feature.dart' as _i385;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_reference_feature/local_reference_feature.dart' as _i804;
import 'package:profile_feature/profile_feature.dart' as _i630;
import 'package:registration_feature/registration_feature.dart' as _i898;
import 'package:sales_feature/sales_feature.dart' as _i248;
import 'package:stock_feature/stock_feature.dart' as _i922;
import 'package:supabase_feature/supabase_feature.dart' as _i375;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i375.SupabaseFeaturePackageModule().init(gh);
    await _i804.LocalReferenceFeaturePackageModule().init(gh);
    await _i630.ProfileFeaturePackageModule().init(gh);
    await _i385.AuthorizationFeaturePackageModule().init(gh);
    await _i898.RegistrationFeaturePackageModule().init(gh);
    await _i248.SalesFeaturePackageModule().init(gh);
    await _i922.StockFeaturePackageModule().init(gh);
    return this;
  }
}
