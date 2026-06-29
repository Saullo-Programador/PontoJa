import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/usecases/register_point_usecase.dart';
import 'package:ponto_eletronico/features/employee/controller/employee_home_controller.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockITimeRecordRepository mockRepo;
  late RegisterPointUsecase usecase;
  late EmployeeHomeController controller;

  setUp(() {
    mockRepo = MockITimeRecordRepository();
    usecase = RegisterPointUsecase(mockRepo);
    controller = EmployeeHomeController(usecase);
  });

  final userId = 'user_abc';
  final now = DateTime.now();
  final date = DateTime(now.year, now.month, now.day);

  group('EmployeeHomeController', () {
    test('estado inicial é idle sem registro', () {
      expect(controller.status, equals(PointStatus.idle));
      expect(controller.todayRecord, isNull);
      expect(controller.hasEntry, isFalse);
      expect(controller.hasExit, isFalse);
    });

    test('loadTodayRecord carrega o registro e atualiza status para idle', () async {
      final record = TimeRecordEntity(
        id: 'r1',
        userId: userId,
        date: date,
        entry: now,
      );
      when(mockRepo.getTodayRecord(userId)).thenAnswer((_) async => record);

      await controller.loadTodayRecord(userId);

      expect(controller.status, equals(PointStatus.idle));
      expect(controller.todayRecord, equals(record));
      expect(controller.hasEntry, isTrue);
      expect(controller.hasExit, isFalse);
    });

    test('loadTodayRecord seta status error em caso de exceção', () async {
      when(mockRepo.getTodayRecord(userId)).thenThrow(Exception('Firestore error'));

      await controller.loadTodayRecord(userId);

      expect(controller.status, equals(PointStatus.error));
      expect(controller.errorMessage, isNotEmpty);
    });

    test('registerPoint registra entrada e recarrega o registro', () async {
      // Primeiro getTodayRecord retorna null (sem registro)
      when(mockRepo.getTodayRecord(userId)).thenAnswer((_) async => null);
      when(mockRepo.registerEntry(any)).thenAnswer((_) async {});

      await controller.registerPoint(userId, PunchStep.entry);

      verify(mockRepo.registerEntry(any)).called(1);
      expect(controller.status, equals(PointStatus.idle));
    });

    test('hasExit é true quando registro tem saída', () async {
      final record = TimeRecordEntity(
        id: 'r1',
        userId: userId,
        date: date,
        entry: now.subtract(const Duration(hours: 8)),
        exit: now,
      );
      when(mockRepo.getTodayRecord(userId)).thenAnswer((_) async => record);

      await controller.loadTodayRecord(userId);

      expect(controller.hasEntry, isTrue);
      expect(controller.hasExit, isTrue);
    });
  });
}