// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_feature/src/core/supabase_client.dart' as _i1030;

class SupabaseFeaturePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) async {
    gh.factory<_i1030.SupabaseConfig>(() => _i1030.SupabaseConfig(
          url: gh<String>(instanceName: 'supabaseUrl'),
          publishableKey: gh<String>(instanceName: 'supabaseKey'),
        ));
    await gh.singletonAsync<_i1030.SupabaseService>(
      () => _i1030.SupabaseService(gh<_i1030.SupabaseConfig>()).init(),
      preResolve: true,
    );
  }
}
