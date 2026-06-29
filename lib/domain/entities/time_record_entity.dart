class TimeRecordEntity {
  final String? id;
  final String userId;
  final DateTime date;
  final DateTime entry;
  final DateTime? breakStart;   // início do intervalo
  final DateTime? breakEnd;     // fim do intervalo (voltou)
  final DateTime? exit;

  const TimeRecordEntity({
    this.id,
    required this.userId,
    required this.date,
    required this.entry,
    this.breakStart,
    this.breakEnd,
    this.exit,
  });

  // ── Estado atual do ponto ────────────────────────────────────────────────

  bool get hasEntry      => true;               // entry é obrigatório
  bool get hasBreakStart => breakStart != null;
  bool get hasBreakEnd   => breakEnd != null;
  bool get hasExit       => exit != null;

  /// Em intervalo = iniciou mas ainda não voltou
  bool get isOnBreak => hasBreakStart && !hasBreakEnd;

  /// Completo = tem saída
  bool get isComplete => hasExit;

  /// Próxima ação esperada
  PunchStep get nextStep {
    if (!hasBreakStart) return PunchStep.breakStart;
    if (!hasBreakEnd)   return PunchStep.breakEnd;
    if (!hasExit)       return PunchStep.exit;
    return PunchStep.done;
  }

  // ── Cálculo de horas ────────────────────────────────────────────────────

  /// Tempo total trabalhado descontando o intervalo
  Duration? get workedDuration {
    if (!hasExit) return null;
    final total = exit!.difference(entry);
    final breakTime = (hasBreakStart && hasBreakEnd)
        ? breakEnd!.difference(breakStart!)
        : Duration.zero;
    return total - breakTime;
  }

  TimeRecordEntity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? entry,
    DateTime? breakStart,
    DateTime? breakEnd,
    DateTime? exit,
  }) {
    return TimeRecordEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      entry: entry ?? this.entry,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
      exit: exit ?? this.exit,
    );
  }
}

enum PunchStep { breakStart, breakEnd, exit, done }