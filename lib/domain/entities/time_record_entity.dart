class BreakRecord {
  final DateTime start;
  final DateTime? end;

  const BreakRecord({
    required this.start,
    this.end,
  });

  bool get isOpen => end == null;

  BreakRecord copyWith({
    DateTime? start,
    DateTime? end,
  }) {
    return BreakRecord(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class TimeRecordEntity {
  final String? id;
  final String userId;
  final DateTime date;
  final DateTime entry;
  final List<BreakRecord> breaks;
  final DateTime? exit;

  const TimeRecordEntity({
    this.id,
    required this.userId,
    required this.date,
    required this.entry,
    this.breaks = const [],
    this.exit,
  });

  bool get hasEntry => true;

  bool get hasBreakStart => breaks.isNotEmpty;

  bool get hasBreakEnd =>
      breaks.any((b) => b.end != null);

  bool get hasExit => exit != null;

  bool get isOnBreak =>
      breaks.any((b) => b.isOpen);

  bool get isComplete => exit != null;

  bool get canStartBreak =>
    breaks.length < 3 &&
    !isOnBreak &&
    exit == null;

  bool get canExit =>
    !isOnBreak &&
    exit == null;

  PunchStep get nextStep {
    if (isOnBreak) {
      return PunchStep.breakEnd;
    }

    if (exit == null) {
      return PunchStep.exit;
    }

    return PunchStep.done;
  }

  Duration? get workedDuration {
    if (exit == null) return null;

    final total = exit!.difference(entry);

    final breakTime = breaks.fold(
      Duration.zero,
      (sum, b) {
        if (b.end != null) {
          return sum + b.end!.difference(b.start);
        }
        return sum;
      },
    );

    return total - breakTime;
  }

  TimeRecordEntity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? entry,
    List<BreakRecord>? breaks,
    DateTime? exit,
  }) {
    return TimeRecordEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      entry: entry ?? this.entry,
      breaks: breaks ?? this.breaks,
      exit: exit ?? this.exit,
    );
  }
}

enum PunchStep {
  entry,
  breakStart,
  breakEnd,
  exit,
  done,
}