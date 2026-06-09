import 'package:authorization_feature/authorization_feature.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:profile_feature/profile_feature.dart';
import 'package:registration_feature/registration_feature.dart';
import 'package:stock_pro/di/injection.config.dart';
import 'package:supabase_feature/supabase_feature.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Named instance key for Supabase URL.
const supabaseUrlName = 'supabaseUrl';

/// Named instance key for Supabase publishable key.
const supabaseKeyName = 'supabaseKey';

/// Configuration values for Supabase - read from Dart define or environment.
String get supabaseUrl {
  const fromDefine = String.fromEnvironment('SUPABASE_URL');
  if (fromDefine.isNotEmpty) return fromDefine;

  throw Exception(
    'SUPABASE_URL not configured. '
    'Pass it via --dart-define=SUPABASE_URL=...',
  );
}

/// Configuration values for Supabase - read from Dart define or environment.
String get supabaseKey {
  const fromDefine = String.fromEnvironment('SUPABASE_KEY');
  if (fromDefine.isNotEmpty) return fromDefine;

  throw Exception(
    'SUPABASE_KEY not configured. '
    'Pass it via --dart-define=SUPABASE_KEY=...',
  );
}

/// Registers app-level values required by feature micropackages.
void registerPreDependencies() {
  getIt
    ..registerLazySingleton<String>(
      () => supabaseUrl,
      instanceName: supabaseUrlName,
    )
    ..registerLazySingleton<String>(
      () => supabaseKey,
      instanceName: supabaseKeyName,
    );
}

/// Configures all dependencies via injectable micropackages.
@InjectableInit(
  externalPackageModulesBefore: [
    ExternalModule(SupabaseFeaturePackageModule),
    ExternalModule(ProfileFeaturePackageModule),
    ExternalModule(AuthorizationFeaturePackageModule),
    ExternalModule(RegistrationFeaturePackageModule),
  ],
)
Future<GetIt> configureDependencies() async {
  registerPreDependencies();
  return getIt.init();
}
