/// Application user role stored in Supabase `users.role`.
enum UserRole {
  /// Regular staff member — checkout and read-only stock.
  staff('staff'),

  /// Administrator — stock management and sales history.
  admin('admin');

  const UserRole(this.value);

  /// Value persisted in the database.
  final String value;

  /// Human-readable label for UI.
  String get label => switch (this) {
    UserRole.staff => 'Сотрудник',
    UserRole.admin => 'Администратор',
  };

  /// Parses a database value, defaulting to [staff] for unknown values.
  static UserRole fromDbValue(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.staff,
    );
  }
}
