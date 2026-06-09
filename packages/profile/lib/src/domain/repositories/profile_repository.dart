import '../models/user_profile.dart';

/// Contract for loading and persisting user profile data.
///
/// Implementations may use Supabase, local storage, REST API, etc.
abstract class ProfileRepository {
  /// Returns the authenticated user id, or null if not signed in.
  Future<String?> getCurrentUserId();

  /// Loads profile by [userId].
  Future<UserProfile?> getProfile(String userId);

  /// Persists a new user profile.
  Future<void> createProfile({
    required String userId,
    required String creds,
    required String email,
    required String password,
    required String role,
  });

  /// Signs the current user out.
  Future<void> signOut();
}
