import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import '../../domain/models/registration_data.dart';
import '../../domain/models/registration_result.dart';
import '../../domain/repositories/registration_repository.dart';

@Injectable(as: RegistrationRepository)
class SupabaseRegistrationRepository implements RegistrationRepository {
  SupabaseRegistrationRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  @override
  Future<RegistrationResult> register(RegistrationData data) async {
    final response = await _supabaseService.client.auth.signUp(
      email: data.email.trim(),
      password: data.password,
      data: _userMetadata(data),
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Не удалось зарегистрироваться');
    }

    return RegistrationResult(
      userId: user.id,
      hasSession: response.session != null,
    );
  }

  Map<String, dynamic> _userMetadata(RegistrationData data) {
    return {
      'creds': data.creds,
      'role': data.role.value,
    };
  }
}
