import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';

class TimeRecordModel extends TimeRecordEntity {
  const TimeRecordModel({
    super.id,
    required super.userId,
    required super.date,
    required super.entry,
    super.breakStart,
    super.breakEnd,
    super.exit,
  });

  factory TimeRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeRecordModel(
      id: doc.id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      entry: (data['entry'] as Timestamp).toDate(),
      breakStart: data['breakStart'] != null
          ? (data['breakStart'] as Timestamp).toDate()
          : null,
      breakEnd: data['breakEnd'] != null
          ? (data['breakEnd'] as Timestamp).toDate()
          : null,
      exit: data['exit'] != null
          ? (data['exit'] as Timestamp).toDate()
          : null,
    );
  }

  factory TimeRecordModel.fromEntity(TimeRecordEntity e) => TimeRecordModel(
        id: e.id,
        userId: e.userId,
        date: e.date,
        entry: e.entry,
        breakStart: e.breakStart,
        breakEnd: e.breakEnd,
        exit: e.exit,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'entry': Timestamp.fromDate(entry),
        'breakStart':
            breakStart != null ? Timestamp.fromDate(breakStart!) : null,
        'breakEnd': breakEnd != null ? Timestamp.fromDate(breakEnd!) : null,
        'exit': exit != null ? Timestamp.fromDate(exit!) : null,
      };
}