import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('retorna erro para e-mail vazio', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('retorna erro para e-mail inválido', () {
      expect(Validators.email('nao-é-email'), isNotNull);
      expect(Validators.email('sem@dominio'), isNotNull);
      expect(Validators.email('@semlocal.com'), isNotNull);
    });

    test('retorna null para e-mail válido', () {
      expect(Validators.email('usuario@empresa.com'), isNull);
      expect(Validators.email('a@b.co'), isNull);
    });
  });

  group('Validators.password', () {
    test('retorna erro para senha com menos de 6 caracteres', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
    });

    test('retorna null para senha com 6 ou mais caracteres', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('senha_forte_123'), isNull);
    });
  });

  group('Validators.required', () {
    test('retorna erro para campo vazio ou null', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
      expect(Validators.required(null), isNotNull);
    });

    test('retorna null para campo preenchido', () {
      expect(Validators.required('João'), isNull);
    });

    test('inclui o nome do campo na mensagem de erro', () {
      final msg = Validators.required('', 'Nome');
      expect(msg, contains('Nome'));
    });
  });
}