import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';

class RegisterPointUsecase {
  final ITimeRecordRepository _repository;

  RegisterPointUsecase(this._repository);

  /// Registra entrada ou saída dependendo do estado atual.
  Future<void> execute(String userId) async {
    final existing = await _repository.getTodayRecord(userId);

    if (existing == null) {
      // Sem registro hoje → bate entrada
      final now = DateTime.now();
      final record = TimeRecordEntity(
        userId: userId,
        date: DateTime(now.year, now.month, now.day),
        entry: now,
      );
      await _repository.registerEntry(record);
    } else if (!existing.hasExit) {
      // Tem entrada mas não saída → bate saída
      await _repository.registerExit(existing.id!, DateTime.now());
    }
    // Se já tem entrada e saída, não faz nada (ponto completo)
  }

  Future<TimeRecordEntity?> getTodayRecord(String userId) =>
      _repository.getTodayRecord(userId);
}