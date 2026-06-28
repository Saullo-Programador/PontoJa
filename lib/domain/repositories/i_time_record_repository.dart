import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';

abstract class ITimeRecordRepository {
  Future<void> registerEntry(TimeRecordEntity record);
  Future<void> registerExit(String recordId, DateTime exit);
  Future<TimeRecordEntity?> getTodayRecord(String userId);
  Future<List<TimeRecordEntity>> getMonthlyRecords(
    String userId, {
    required int month,
    required int year,
  });
  Future<List<TimeRecordEntity>> getAllTodayRecords();
  Future<List<TimeRecordEntity>> getAllMonthlyRecords({
    required int month,
    required int year,
  });
  Future<void> updateRecord(TimeRecordEntity record);
}