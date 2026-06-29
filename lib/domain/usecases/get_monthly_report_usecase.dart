import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';

class GetMonthlyReportUsecase {
  final ITimeRecordRepository _repository;

  GetMonthlyReportUsecase(this._repository);

  // ── Futures (relatório / export) ─────────────────────────────────────────

  Future<List<TimeRecordEntity>> execute({
    required int month,
    required int year,
  }) =>
      _repository.watchMonthlyRecords(month: month, year: year).first;

  Future<List<TimeRecordEntity>> executeForUser({
    required String userId,
    required int month,
    required int year,
  }) =>
      _repository.getMonthlyRecords(userId, month: month, year: year);

  // ── Streams (tempo real para o gerente) ──────────────────────────────────

  Stream<List<TimeRecordEntity>> watchTodayAll() =>
      _repository.watchTodayRecords();

  Stream<List<TimeRecordEntity>> watchMonthly({
    required int month,
    required int year,
  }) =>
      _repository.watchMonthlyRecords(month: month, year: year);
}