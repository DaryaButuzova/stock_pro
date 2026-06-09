import '../models/registration_data.dart';
import '../models/registration_result.dart';

/// Contract for user registration.
///
/// Implementations may use Supabase, REST API, local storage, etc.
abstract class RegistrationRepository {
  /// Registers a new user and persists profile data.
  Future<RegistrationResult> register(RegistrationData data);
}
