extension AppDateUtils on DateTime {
  /// Retorna true se duas datas caírem no mesmo dia.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Início do dia (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Fim do dia (23:59:59).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Início do mês.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Início do próximo mês (usado como limite exclusivo de query).
  DateTime get startOfNextMonth =>
      month == 12 ? DateTime(year + 1, 1) : DateTime(year, month + 1);

  /// Formata como "dd/MM/yyyy HH:mm".
  String toDisplay() {
    final d = '$day'.padLeft(2, '0');
    final m = '$month'.padLeft(2, '0');
    final h = '$hour'.padLeft(2, '0');
    final min = '$minute'.padLeft(2, '0');
    return '$d/$m/$year $h:$min';
  }

  /// Formata como "dd/MM/yyyy".
  String toDateDisplay() {
    final d = '$day'.padLeft(2, '0');
    final m = '$month'.padLeft(2, '0');
    return '$d/$m/$year';
  }
}