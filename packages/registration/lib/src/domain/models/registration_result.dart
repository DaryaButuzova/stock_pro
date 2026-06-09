/// Result of a registration attempt.
class RegistrationResult {
  const RegistrationResult({
    required this.userId,
    required this.hasSession,
  });

  /// ID of the created auth user.
  final String userId;

  /// Whether the user received an active session immediately.
  final bool hasSession;
}
