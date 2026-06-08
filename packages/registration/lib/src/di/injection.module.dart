// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:registration_feature/src/domain/registration_cubit.dart'
    as _i74;
import 'package:supabase_feature/supabase_feature.dart' as _i375;

class RegistrationFeaturePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i74.RegistrationCubit>(
        () => _i74.RegistrationCubit(gh<_i375.SupabaseService>()));
  }
}
