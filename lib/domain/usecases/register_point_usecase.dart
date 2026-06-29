import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';
import 'package:ponto_eletronico/domain/usecases/check_location_usecase.dart';

class RegisterPointUsecase {
  final ITimeRecordRepository _repository;
  final CheckLocationUsecase? _checkLocation; // nullable: pode não ter GPS

  RegisterPointUsecase(this._repository, [this._checkLocation]);

  Future<PunchStep> execute(String userId) async {
    // ── Verifica localização antes de registrar ──────────────────────────
    if (_checkLocation != null) {
      final result = await _checkLocation.execute();
      if (!result.allowed) {
        throw LocationPunchException(result.errorMessage ?? 'Localização inválida.');
      }
    }

    final existing = await _repository.getTodayRecord(userId);

    if (existing == null) {
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
        await _repository.updateRecord(existing.copyWith(breakStart: now));
        return PunchStep.breakEnd;

      case PunchStep.breakEnd:
        await _repository.updateRecord(existing.copyWith(breakEnd: now));
        return PunchStep.exit;

      case PunchStep.exit:
        await _repository.updateRecord(existing.copyWith(exit: now));
        return PunchStep.done;

      case PunchStep.done:
        return PunchStep.done;
    }
  }

  Future<TimeRecordEntity?> getTodayRecord(String userId) =>
      _repository.getTodayRecord(userId);
}

/// Lançada quando o funcionário está fora do raio permitido.
class LocationPunchException implements Exception {
  final String message;
  const LocationPunchException(this.message);

  @override
  String toString() => message;
}