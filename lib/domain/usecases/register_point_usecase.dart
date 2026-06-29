import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';

class RegisterPointUsecase {
  final ITimeRecordRepository _repository;

  RegisterPointUsecase(this._repository);

  /// Avança o ponto para a próxima etapa automaticamente:
  /// sem registro → entrada
  /// entrada feita → iniciar intervalo
  /// em intervalo  → voltar do intervalo
  /// voltou        → saída
  Future<PunchStep> execute(String userId) async {
    final existing = await _repository.getTodayRecord(userId);

    if (existing == null) {
      // ── Bate entrada ─────────────────────────────────────────────────
      final now = DateTime.now();
      await _repository.registerEntry(TimeRecordEntity(
        userId: userId,
        date: DateTime(now.year, now.month, now.day),
        entry: now,
      ));
      return PunchStep.breakStart;
    }

    final now = DateTime.now();

    switch (existing.nextStep) {
      case PunchStep.breakStart:
        await _repository.updateRecord(
          existing.copyWith(breakStart: now),
        );
        return PunchStep.breakEnd;

      case PunchStep.breakEnd:
        await _repository.updateRecord(
          existing.copyWith(breakEnd: now),
        );
        return PunchStep.exit;

      case PunchStep.exit:
        await _repository.updateRecord(
          existing.copyWith(exit: now),
        );
        return PunchStep.done;

      case PunchStep.done:
        return PunchStep.done; // ponto completo, não faz nada
    }
  }

  Future<TimeRecordEntity?> getTodayRecord(String userId) =>
      _repository.getTodayRecord(userId);
}