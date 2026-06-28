import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/usecases/edit_point_usecase.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockITimeRecordRepository mockRepo;
  late EditPointUsecase usecase;

  setUp(() {
    mockRepo = MockITimeRecordRepository();
    usecase = EditPointUsecase(mockRepo);
  });

  group('EditPointUsecase', () {
    test('chama updateRecord com o registro correto', () async {
      final record = TimeRecordEntity(
        id: 'rec_1',
        userId: 'u1',
        date: DateTime(2025, 6, 1),
        entry: DateTime(2025, 6, 1, 8, 0),
        exit: DateTime(2025, 6, 1, 17, 30),
      );
      when(mockRepo.updateRecord(record)).thenAnswer((_) async {});

      await usecase.execute(record);

      verify(mockRepo.updateRecord(record)).called(1);
    });
  });
}