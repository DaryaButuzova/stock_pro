import 'package:supabase_feature/supabase_feature.dart';

/// Maps registration errors to short Russian messages for the UI.
String mapRegistrationError(Object error) {
  if (error is AuthException) {
    return _mapAuthException(error);
  }

  if (error is UserAlreadyRegisteredException) {
    return error.message;
  }

  return _mapFromText(error.toString()) ??
      'Не удалось зарегистрироваться. Попробуйте позже.';
}

String _mapAuthException(AuthException error) {
  final code = error.code?.toLowerCase();
  final message = error.message.toLowerCase();

  if (_looksLikeAlreadyRegistered(code, message)) {
    return _alreadyRegisteredMessage;
  }

  if (code == 'weak_password' || message.contains('weak password')) {
    return 'Пароль слишком простой';
  }

  return _mapFromText(error.message) ??
      'Не удалось зарегистрироваться. Попробуйте позже.';
}

const _alreadyRegisteredMessage =
    'Пользователь с таким email уже зарегистрирован';

bool _looksLikeAlreadyRegistered(String? code, String message) {
  if (code == 'user_already_exists' || code == 'email_exists') {
    return true;
  }

  return message.contains('already registered') ||
      message.contains('already exists') ||
      message.contains('user already') ||
      message.contains('уже зарегистрирован');
}

String? _mapFromText(String text) {
  final lower = text.toLowerCase();

  if (_looksLikeAlreadyRegistered(null, lower)) {
    return _alreadyRegisteredMessage;
  }

  if (lower.contains('duplicate key') || lower.contains('unique constraint')) {
    return _alreadyRegisteredMessage;
  }

  return null;
}

/// Thrown when [signUp] returns an existing user without new identities.
class UserAlreadyRegisteredException implements Exception {
  const UserAlreadyRegisteredException([
    this.message = _alreadyRegisteredMessage,
  ]);

  final String message;

  @override
  String toString() => message;
}
