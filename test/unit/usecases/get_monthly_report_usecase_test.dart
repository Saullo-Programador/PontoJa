import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/usecases/get_monthly_report_usecase.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockITimeRecordRepository mockRepo;
  late GetMonthlyReportUsecase usecase;

  setUp(() {
    mockRepo = MockITimeRecordRepository();
    usecase = GetMonthlyReportUsecase(mockRepo);
  });

  final records = [
    TimeRecordEntity(
      id: '1',
      userId: 'u1',
      date: DateTime(2025, 6, 1),
      entry: DateTime(2025, 6, 1, 8, 0),
      exit: DateTime(2025, 6, 1, 17, 0),
    ),
    TimeRecordEntity(
      id: '2',
      userId: 'u2',
      date: DateTime(2025, 6, 2),
      entry: DateTime(2025, 6, 2, 9, 0),
    ),
  ];

  group('GetMonthlyReportUsecase', () {
    test('execute retorna todos os registros do mês', () async {
      when(mockRepo.getAllMonthlyRecords(month: 6, year: 2025))
          .thenAnswer((_) async => records);

      final result = await usecase.execute(month: 6, year: 2025);

      expect(result, equals(records));
      verify(mockRepo.getAllMonthlyRecords(month: 6, year: 2025)).called(1);
    });

    test('executeForUser filtra registros por usuário', () async {
      final userRecords = records.where((r) => r.userId == 'u1').toList();
      when(mockRepo.getMonthlyRecords('u1', month: 6, year: 2025))
          .thenAnswer((_) async => userRecords);

      final result = await usecase.executeForUser(
        userId: 'u1',
        month: 6,
        year: 2025,
      );

      expect(result.length, equals(1));
      expect(result.first.userId, equals('u1'));
    });

    test('getTodayAll retorna os registros de hoje', () async {
      when(mockRepo.getAllTodayRecords()).thenAnswer((_) async => records);

      final result = await usecase.getTodayAll();

      expect(result, equals(records));
      verify(mockRepo.getAllTodayRecords()).called(1);
    });
  });
}