// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:authorization_feature/src/data/repositories/supabase_auth_repository.dart'
    as _i347;
import 'package:authorization_feature/src/domain/authorization_cubit.dart'
    as _i1015;
import 'package:authorization_feature/src/domain/repositories/auth_repository.dart'
    as _i542;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_feature/supabase_feature.dart' as _i375;

class AuthorizationFeaturePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i542.AuthRepository>(
        () => _i347.SupabaseAuthRepository(gh<_i375.SupabaseService>()));
    gh.factory<_i1015.AuthorizationCubit>(
        () => _i1015.AuthorizationCubit(gh<_i542.AuthRepository>()));
  }
}
