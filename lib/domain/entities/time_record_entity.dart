class TimeRecordEntity {
  final String? id;
  final String userId;
  final DateTime date;
  final DateTime entry;
  final DateTime? exit;

  const TimeRecordEntity({
    this.id,
    required this.userId,
    required this.date,
    required this.entry,
    this.exit,
  });

  bool get hasExit => exit != null;

  Duration? get workedDuration =>
      exit != null ? exit!.difference(entry) : null;

  TimeRecordEntity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? entry,
    DateTime? exit,
  }) {
    return TimeRecordEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      entry: entry ?? this.entry,
      exit: exit ?? this.exit,
    );
  }
}