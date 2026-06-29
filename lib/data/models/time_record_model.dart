import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';

class TimeRecordModel extends TimeRecordEntity {
  const TimeRecordModel({
    super.id,
    required super.userId,
    required super.date,
    required super.entry,
    super.breaks,
    super.exit,
  });

  factory TimeRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final breaksData = data['breaks'] as List<dynamic>? ?? [];

    return TimeRecordModel(
      id: doc.id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      entry: (data['entry'] as Timestamp).toDate(),
      breaks: breaksData.map((b) {
        return BreakRecord(
          start: (b['start'] as Timestamp).toDate(),
          end: b['end'] != null ? (b['end'] as Timestamp).toDate() : null,
        );
      }).toList(),
      exit: data['exit'] != null ? (data['exit'] as Timestamp).toDate() : null,
    );
  }

  factory TimeRecordModel.fromEntity(TimeRecordEntity e) => TimeRecordModel(
    id: e.id,
    userId: e.userId,
    date: e.date,
    entry: e.entry,
    breaks: e.breaks,
    exit: e.exit,
  );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'date': Timestamp.fromDate(date),
    'entry': Timestamp.fromDate(entry),
    'breaks': breaks
        .map(
          (b) => {
            'start': Timestamp.fromDate(b.start),
            'end': b.end != null ? Timestamp.fromDate(b.end!) : null,
          },
        )
        .toList(),
    'exit': exit != null ? Timestamp.fromDate(exit!) : null,
  };
}
