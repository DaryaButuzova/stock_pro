import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../data/database/app_database.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [SupabaseService],
)
void initLocalReferenceMicroPackage() {}

@module
abstract class LocalReferenceDatabaseModule {
  @lazySingleton
  AppDatabase appDatabase() => AppDatabase();
}
