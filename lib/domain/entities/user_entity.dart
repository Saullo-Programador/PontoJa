class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String username; // login simplificado ex: "joao.silva"
  final String role;     // 'employee' | 'manager'

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
  });

  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'employee':
        return 'Funcionário';
      case 'manager':
        return 'Gerente';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  bool get isManager  => role == 'manager';
  bool get isEmployee => role == 'employee';

  static String usernameToEmail(String username) =>
      '${username.trim().toLowerCase()}@ponto.app';
}