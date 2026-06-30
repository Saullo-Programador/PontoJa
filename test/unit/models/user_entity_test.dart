import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('isManager retorna true quando role é manager', () {
      const user = UserEntity(
        uid: 'u1',
        username: 'joao',
        name: 'João',
        email: 'joao@empresa.com',
        role: 'manager',
      );
      expect(user.isManager, isTrue);
      expect(user.isEmployee, isFalse);
    });

    test('isEmployee retorna true quando role é employee', () {
      const user = UserEntity(
        uid: 'u2',
        username: 'maria',
        name: 'Maria',
        email: 'maria@empresa.com',
        role: 'employee',
      );
      expect(user.isEmployee, isTrue);
      expect(user.isManager, isFalse);
    });
  });
}