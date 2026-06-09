import '../models/registration_data.dart';
import '../models/registration_result.dart';

/// Contract for user registration (auth sign-up).
///
/// Implementations may use Supabase, Firebase, REST API, etc.
/// Persisting profile data is orchestrated by [RegistrationCubit].
abstract class RegistrationRepository {
  /// Registers a new user in the auth system.
  Future<RegistrationResult> register(RegistrationData data);
}
