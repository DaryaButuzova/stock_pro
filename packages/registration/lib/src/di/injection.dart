import 'package:injectable/injectable.dart';
import 'package:profile_feature/profile_feature.dart';
import 'package:supabase_feature/supabase_feature.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    ProfileRepository,
    SupabaseService,
  ],
)
void initRegistrationMicroPackage() {}
