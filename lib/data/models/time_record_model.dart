import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';

class TimeRecordModel extends TimeRecordEntity {
  const TimeRecordModel({
    super.id,
    required super.userId,
    required super.date,
    required super.entry,
    super.exit,
  });

  factory TimeRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeRecordModel(
      id: doc.id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      entry: (data['entry'] as Timestamp).toDate(),
      exit: data['exit'] != null
          ? (data['exit'] as Timestamp).toDate()
          : null,
    );
  }

  factory TimeRecordModel.fromEntity(TimeRecordEntity entity) =>
      TimeRecordModel(
        id: entity.id,
        userId: entity.userId,
        date: entity.date,
        entry: entity.entry,
        exit: entity.exit,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'entry': Timestamp.fromDate(entry),
        'exit': exit != null ? Timestamp.fromDate(exit!) : null,
      };
}