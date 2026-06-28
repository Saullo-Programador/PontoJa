import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/usecases/register_point_usecase.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockITimeRecordRepository mockRepo;
  late RegisterPointUsecase usecase;

  setUp(() {
    mockRepo = MockITimeRecordRepository();
    usecase = RegisterPointUsecase(mockRepo);
  });

  final userId = 'user_123';
  final now = DateTime.now();
  final date = DateTime(now.year, now.month, now.day);

  group('RegisterPointUsecase', () {
    test('registra entrada quando não há registro hoje', () async {
      when(mockRepo.getTodayRecord(userId)).thenAnswer((_) async => null);
      when(mockRepo.registerEntry(any)).thenAnswer((_) async {});

      await usecase.execute(userId);

      verify(mockRepo.registerEntry(any)).called(1);
      verifyNever(mockRepo.registerExit(any, any));
    });

    test('registra saída quando há entrada sem saída', () async {
      final existingRecord = TimeRecordEntity(
        id: 'rec_1',
        userId: userId,
        date: date,
        entry: now.subtract(const Duration(hours: 8)),
      );
      when(mockRepo.getTodayRecord(userId))
          .thenAnswer((_) async => existingRecord);
      when(mockRepo.registerExit(any, any)).thenAnswer((_) async {});

      await usecase.execute(userId);

      verify(mockRepo.registerExit('rec_1', any)).called(1);
      verifyNever(mockRepo.registerEntry(any));
    });

    test('não faz nada quando ponto já está completo', () async {
      final completeRecord = TimeRecordEntity(
        id: 'rec_1',
        userId: userId,
        date: date,
        entry: now.subtract(const Duration(hours: 8)),
        exit: now,
      );
      when(mockRepo.getTodayRecord(userId))
          .thenAnswer((_) async => completeRecord);

      await usecase.execute(userId);

      verifyNever(mockRepo.registerEntry(any));
      verifyNever(mockRepo.registerExit(any, any));
    });

    test('getTodayRecord delega para o repositório', () async {
      when(mockRepo.getTodayRecord(userId)).thenAnswer((_) async => null);

      final result = await usecase.getTodayRecord(userId);

      expect(result, isNull);
      verify(mockRepo.getTodayRecord(userId)).called(1);
    });
  });
}