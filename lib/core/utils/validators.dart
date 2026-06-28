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
}