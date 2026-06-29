import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';
import 'package:ponto_eletronico/domain/usecases/check_location_usecase.dart';

class RegisterPointUsecase {
  final ITimeRecordRepository _repository;
  final CheckLocationUsecase? _checkLocation;

  RegisterPointUsecase(
    this._repository, {
    CheckLocationUsecase? checkLocation,
  }) : _checkLocation = checkLocation;

  Future<PunchStep> execute(String userId,  PunchStep action) async {
    if (_checkLocation != null) {
      final result = await _checkLocation.execute();

      if (!result.allowed) {
        throw LocationPunchException(
          result.errorMessage ??
              'Localização inválida.',
        );
      }
    }

    final existing =
        await _repository.getTodayRecord(userId);

    // PRIMEIRA BATIDA (ENTRADA)
    if (existing == null) {
      final now = DateTime.now();

      await _repository.registerEntry(
        TimeRecordEntity(
          userId: userId,
          date: DateTime(
            now.year,
            now.month,
            now.day,
          ),
          entry: now,
        ),
      );

      return PunchStep.entry;
    }

    final now = DateTime.now();

    switch (existing.nextStep) {
      case PunchStep.entry:
        return PunchStep.entry;

      case PunchStep.breakStart:
        final breaks = [...existing.breaks];

        breaks.add(
          BreakRecord(start: now),
        );

        await _repository.updateRecord(
          existing.copyWith(
            breaks: breaks,
          ),
        );

        return PunchStep.breakStart;

      case PunchStep.breakEnd:
        final breaks = [...existing.breaks];

        final index = breaks.indexWhere(
          (b) => b.isOpen,
        );

        if (index == -1) {
          throw StateError(
            'Nenhum intervalo aberto.',
          );
        }

        breaks[index] =
            breaks[index].copyWith(
          end: now,
        );

        await _repository.updateRecord(
          existing.copyWith(
            breaks: breaks,
          ),
        );

        return PunchStep.breakEnd;

      case PunchStep.exit:
        await _repository.updateRecord(
          existing.copyWith(
            exit: now,
          ),
        );

        return PunchStep.exit;

      case PunchStep.done:
        return PunchStep.done;
    }
  }

  Future<TimeRecordEntity?> getTodayRecord(
    String userId,
  ) {
    return _repository.getTodayRecord(userId);
  }
}

class LocationPunchException
    implements Exception {
  final String message;

  const LocationPunchException(
    this.message,
  );

  @override
  String toString() => message;
}