import 'package:supabase_feature/supabase_feature.dart';

/// Maps sign-in errors to short Russian messages for the UI.
String mapSignInError(Object error) {
  if (error is AuthException) {
    return _mapAuthException(error);
  }

  return _mapFromText(error.toString()) ??
      'Не удалось войти. Проверьте email и пароль.';
}

String _mapAuthException(AuthException error) {
  final code = error.code?.toLowerCase();
  final message = error.message.toLowerCase();

  if (code == 'user_not_found' || _looksLikeUserNotFound(message)) {
    return 'Пользователь не найден';
  }

  if (code == 'invalid_credentials' || _looksLikeInvalidPassword(message)) {
    return 'Неверный пароль';
  }

  if (code == 'email_not_confirmed' || message.contains('email not confirmed')) {
    return 'Подтвердите email перед входом';
  }

  return _mapFromText(error.message) ??
      'Не удалось войти. Проверьте email и пароль.';
}

bool _looksLikeUserNotFound(String message) {
  return message.contains('user not found') ||
      message.contains('no user') ||
      message.contains('пользователь не найден');
}

bool _looksLikeInvalidPassword(String message) {
  return message.contains('invalid login credentials') ||
      message.contains('invalid credentials') ||
      message.contains('wrong password') ||
      message.contains('неверный пароль');
}

String? _mapFromText(String text) {
  final lower = text.toLowerCase();

  if (_looksLikeUserNotFound(lower)) {
    return 'Пользователь не найден';
  }
  if (_looksLikeInvalidPassword(lower)) {
    return 'Неверный пароль';
  }

  return null;
}
