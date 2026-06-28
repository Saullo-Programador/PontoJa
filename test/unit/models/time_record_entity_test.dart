import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';

void main() {
  group('TimeRecordEntity', () {
    final entry = DateTime(2025, 6, 1, 8, 0);
    final exit  = DateTime(2025, 6, 1, 17, 0);
    final date  = DateTime(2025, 6, 1);

    test('hasExit retorna false quando exit é null', () {
      final record = TimeRecordEntity(
        userId: 'u1',
        date: date,
        entry: entry,
      );
      expect(record.hasExit, isFalse);
    });

    test('hasExit retorna true quando exit está preenchido', () {
      final record = TimeRecordEntity(
        userId: 'u1',
        date: date,
        entry: entry,
        exit: exit,
      );
      expect(record.hasExit, isTrue);
    });

    test('workedDuration calcula corretamente 9 horas', () {
      final record = TimeRecordEntity(
        userId: 'u1',
        date: date,
        entry: entry,
        exit: exit,
      );
      expect(record.workedDuration, equals(const Duration(hours: 9)));
    });

    test('workedDuration é null quando não há saída', () {
      final record = TimeRecordEntity(
        userId: 'u1',
        date: date,
        entry: entry,
      );
      expect(record.workedDuration, isNull);
    });

    test('copyWith substitui apenas os campos fornecidos', () {
      final original = TimeRecordEntity(
        id: 'id1',
        userId: 'u1',
        date: date,
        entry: entry,
      );
      final newExit = DateTime(2025, 6, 1, 18, 0);
      final updated = original.copyWith(exit: newExit);

      expect(updated.id, equals('id1'));
      expect(updated.userId, equals('u1'));
      expect(updated.entry, equals(entry));
      expect(updated.exit, equals(newExit));
    });
  });
}