import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/repositories/auth_repository.dart';

@Injectable(as: AuthRepository)
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseService.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.user == null) {
      throw Exception('Не удалось войти');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseService.client.auth.signOut();
  }
}
