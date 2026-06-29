import 'package:ponto_eletronico/data/datasources/firestore_point_datasource.dart';
import 'package:ponto_eletronico/data/models/time_record_model.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';

class TimeRecordRepositoryImpl implements ITimeRecordRepository {
  final FirestorePointDatasource _datasource;

  TimeRecordRepositoryImpl(this._datasource);

  @override
  Future<void> registerEntry(TimeRecordEntity record) =>
      _datasource.addRecord(TimeRecordModel.fromEntity(record));

  @override
  Future<void> registerExit(String recordId, DateTime exit) =>
      _datasource.updateRecord(TimeRecordModel(
        id: recordId,
        userId: '',
        date: exit,
        entry: exit,
        exit: exit,
      ));

  @override
  Future<TimeRecordEntity?> getTodayRecord(String userId) =>
      _datasource.getTodayRecord(userId);

  @override
  Future<List<TimeRecordEntity>> getMonthlyRecords(
    String userId, {
    required int month,
    required int year,
  }) =>
      _datasource.getMonthlyRecords(userId, month: month, year: year);

  @override
  Stream<List<TimeRecordEntity>> watchTodayRecords() =>
      _datasource.watchTodayRecords();

  @override
  Stream<List<TimeRecordEntity>> watchMonthlyRecords({
    required int month,
    required int year,
  }) =>
      _datasource.watchMonthlyRecords(month: month, year: year);

  @override
  Future<void> updateRecord(TimeRecordEntity record) =>
      _datasource.updateRecord(TimeRecordModel.fromEntity(record));

  @override
  Future<void> deleteRecord(TimeRecordEntity record) =>
      _datasource.deleteRecord(record.id!);
}