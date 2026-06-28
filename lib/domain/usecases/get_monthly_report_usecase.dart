import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';

class GetMonthlyReportUsecase {
  final ITimeRecordRepository _repository;

  GetMonthlyReportUsecase(this._repository);

  Future<List<TimeRecordEntity>> execute({
    required int month,
    required int year,
  }) =>
      _repository.getAllMonthlyRecords(month: month, year: year);

  Future<List<TimeRecordEntity>> executeForUser({
    required String userId,
    required int month,
    required int year,
  }) =>
      _repository.getMonthlyRecords(userId, month: month, year: year);

  Future<List<TimeRecordEntity>> getTodayAll() =>
      _repository.getAllTodayRecords();
}