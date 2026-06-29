import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';

class DeletePointUsecase {
    final ITimeRecordRepository _repository;
  
    DeletePointUsecase(this._repository);
  
    Future<void> execute(TimeRecordEntity record) async {
      await _repository.deleteRecord(record);
    }
}