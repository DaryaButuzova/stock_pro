import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

@Injectable(as: ProfileRepository)
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  @override
  Future<String?> getCurrentUserId() async {
    return _supabaseService.client.auth.currentUser?.id;
  }

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final data = await _supabaseService.client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return UserProfile.fromJson(data);
  }

  @override
  Future<void> createProfile({
    required String userId,
    required String creds,
    required String email,
    required String password,
    required String role,
  }) async {
    await _supabaseService.client.from('users').insert({
      'id': userId,
      'creds': creds,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  @override
  Future<void> signOut() async {
    await _supabaseService.client.auth.signOut();
  }
}
