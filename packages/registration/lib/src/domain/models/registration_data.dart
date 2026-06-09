import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// Registration form payload.
class RegistrationData extends Equatable {
  const RegistrationData({
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.email,
    required this.password,
    required this.role,
  });

  final String lastName;
  final String firstName;
  final String middleName;
  final String email;
  final String password;
  final UserRole role;

  /// Full name stored in `users.creds` as "Фамилия Имя Отчество".
  String get creds =>
      '${lastName.trim()} ${firstName.trim()} ${middleName.trim()}';

  @override
  List<Object?> get props => [
    lastName,
    firstName,
    middleName,
    email,
    password,
    role,
  ];
}
