// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:profile_feature/src/data/repositories/supabase_profile_repository.dart'
    as _i242;
import 'package:profile_feature/src/domain/profile_cubit.dart' as _i519;
import 'package:profile_feature/src/domain/repositories/profile_repository.dart'
    as _i249;
import 'package:supabase_feature/supabase_feature.dart' as _i375;

class ProfileFeaturePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i249.ProfileRepository>(
        () => _i242.SupabaseProfileRepository(gh<_i375.SupabaseService>()));
    gh.factory<_i519.ProfileCubit>(
        () => _i519.ProfileCubit(gh<_i249.ProfileRepository>()));
  }
}
