/// Result of a registration attempt.
class RegistrationResult {
  const RegistrationResult({required this.hasSession});

  /// Whether the user received an active session immediately.
  final bool hasSession;
}
