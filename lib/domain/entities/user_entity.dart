class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String role; // 'employee' | 'manager'

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isManager => role == 'manager';
  bool get isEmployee => role == 'employee';
}