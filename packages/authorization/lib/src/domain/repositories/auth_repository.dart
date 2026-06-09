/// Contract for user authentication.
///
/// Implementations may use Supabase, Firebase, local auth, etc.
abstract class AuthRepository {
  /// Signs in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  });

  /// Signs the current user out.
  Future<void> signOut();
}
