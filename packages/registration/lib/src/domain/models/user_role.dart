/// Application user role stored in Supabase `users.role`.
enum UserRole {
  /// Regular staff member.
  staff('staff'),

  /// Administrator.
  admin('admin');

  const UserRole(this.value);

  /// Value persisted in the database.
  final String value;

  /// Human-readable label for UI.
  String get label => switch (this) {
    UserRole.staff => 'Сотрудник',
    UserRole.admin => 'Администратор',
  };
}
