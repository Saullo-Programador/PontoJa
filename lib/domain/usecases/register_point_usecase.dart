import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';
import 'package:ponto_eletronico/domain/usecases/check_location_usecase.dart';

class RegisterPointUsecase {
  final ITimeRecordRepository _repository;
  final CheckLocationUsecase? _checkLocation;

  RegisterPointUsecase(this._repository, {CheckLocationUsecase? checkLocation})
    : _checkLocation = checkLocation;

  Future<PunchStep> execute(String userId, PunchStep action) async {
    if (_checkLocation != null) {
      final result = await _checkLocation.execute();

      if (!result.allowed) {
        throw LocationPunchException(
          result.errorMessage ?? 'Localização inválida.',
        );
      }
    }

    final existing = await _repository.getTodayRecord(userId);
    final now = DateTime.now();

    // PRIMEIRA BATIDA (ENTRADA)
    if (existing == null) {
      await _repository.registerEntry(
        TimeRecordEntity(
          userId: userId,
          date: DateTime(now.year, now.month, now.day),
          entry: now,
        ),
      );
      return PunchStep.entry;
    }

    // A partir daqui, a ação é decidida pelo que o funcionário ESCOLHEU tocar,
    // não por um "próximo passo obrigatório".
    switch (action) {
      case PunchStep.entry:
        // já tem entrada, não faz nada
        return PunchStep.entry;

      case PunchStep.breakStart:
        if (!existing.canStartBreak) {
          throw StateError('Não é possível iniciar intervalo agora.');
        }

        final breaks = [...existing.breaks, BreakRecord(start: now)];

        await _repository.updateRecord(existing.copyWith(breaks: breaks));
        return PunchStep.breakStart;

      case PunchStep.breakEnd:
        if (!existing.isOnBreak) {
          throw StateError('Nenhum intervalo aberto.');
        }

        final breaks = [...existing.breaks];
        final index = breaks.indexWhere((b) => b.isOpen);
        breaks[index] = breaks[index].copyWith(end: now);

        await _repository.updateRecord(existing.copyWith(breaks: breaks));
        return PunchStep.breakEnd;

      case PunchStep.exit:
        if (!existing.canExit) {
          throw StateError('Não é possível registrar saída agora.');
        }

        await _repository.updateRecord(existing.copyWith(exit: now));
        return PunchStep.exit;

      case PunchStep.done:
        return PunchStep.done;
    }
  }

  Future<TimeRecordEntity?> getTodayRecord(String userId) {
    return _repository.getTodayRecord(userId);
  }
}

class LocationPunchException implements Exception {
  final String message;

  const LocationPunchException(this.message);

  @override
  String toString() => message;
}
