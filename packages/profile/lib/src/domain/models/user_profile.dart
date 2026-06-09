/// User profile entity.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.creds,
    required this.email,
    required this.role,
    this.createdAt,
  });

  final String id;
  final String creds;
  final String email;
  final String role;
  final DateTime? createdAt;

  /// Human-readable role label.
  String get roleLabel => switch (role) {
    'admin' => 'Администратор',
    'staff' => 'Сотрудник',
    _ => role,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      creds: json['creds'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }
}
