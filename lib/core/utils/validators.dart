abstract class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail obrigatório';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(value.trim())) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? required(String? value, [String label = 'Campo']) {
    if (value == null || value.trim().isEmpty) return '$label obrigatório';
    return null;
  }

  /// Valida username: só letras, números, ponto e underscore, mín 3 chars.
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Usuário obrigatório';
    if (value.trim().length < 3) return 'Mínimo 3 caracteres';
    final re = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!re.hasMatch(value.trim())) {
      return 'Use apenas letras, números, ponto ou underscore';
    }
    return null;
  }

  /// Aceita username simples OU e-mail completo (para a tela de login).
  static String? usernameOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Usuário obrigatório';
    // Se tem @, valida como e-mail
    if (value.contains('@')) return email(value);
    // Senão valida como username
    return username(value);
  }
}