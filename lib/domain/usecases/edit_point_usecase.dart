import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';

class EditPointUsecase {
  final ITimeRecordRepository _repository;

  EditPointUsecase(this._repository);

  Future<void> execute(TimeRecordEntity record) =>
      _repository.updateRecord(record);
}