import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    final date = DateTime(2025, 6, 15, 14, 30);

    test('isSameDay retorna true para o mesmo dia', () {
      final other = DateTime(2025, 6, 15, 8, 0);
      expect(date.isSameDay(other), isTrue);
    });

    test('isSameDay retorna false para dias diferentes', () {
      final other = DateTime(2025, 6, 16, 14, 30);
      expect(date.isSameDay(other), isFalse);
    });

    test('startOfDay retorna meia-noite do mesmo dia', () {
      expect(date.startOfDay, equals(DateTime(2025, 6, 15, 0, 0, 0)));
    });

    test('endOfDay retorna 23:59:59 do mesmo dia', () {
      expect(date.endOfDay, equals(DateTime(2025, 6, 15, 23, 59, 59)));
    });

    test('startOfMonth retorna dia 1 do mês', () {
      expect(date.startOfMonth, equals(DateTime(2025, 6, 1)));
    });

    test('startOfNextMonth retorna dia 1 do próximo mês', () {
      expect(date.startOfNextMonth, equals(DateTime(2025, 7, 1)));
    });

    test('startOfNextMonth em dezembro avança para janeiro do próximo ano', () {
      final dezembro = DateTime(2025, 12, 10);
      expect(dezembro.startOfNextMonth, equals(DateTime(2026, 1, 1)));
    });

    test('toDisplay formata corretamente', () {
      expect(date.toDisplay(), equals('15/06/2025 14:30'));
    });

    test('toDateDisplay formata corretamente', () {
      expect(date.toDateDisplay(), equals('15/06/2025'));
    });
  });
}