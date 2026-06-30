import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ponto_eletronico/domain/usecases/create_employee_usecase.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockIUserRepository mockRepo;
  late CreateEmployeeUsecase usecase;

  setUp(() {
    mockRepo = MockIUserRepository();
    usecase = CreateEmployeeUsecase(mockRepo);
  });

  group('CreateEmployeeUsecase', () {
    test('cria funcionário com role employee por padrão', () async {
      when(
        mockRepo.createEmployee(
          name: anyNamed('name'),
          email: anyNamed('email'),
          password: anyNamed('password'),
          role: anyNamed('role'),
        ),
      ).thenAnswer((_) async {});

      await usecase.execute(
        name: 'Carlos Silva',
        username: 'carlos.silva',
        password: 'senha123',
      );

      verify(
        mockRepo.createEmployee(
          name: 'Carlos Silva',
          email: 'carlos@empresa.com',
          password: 'senha123',
          role: 'employee',
        ),
      ).called(1);
    });

    test('cria gerente quando role é manager', () async {
      when(
        mockRepo.createEmployee(
          name: anyNamed('name'),
          email: anyNamed('email'),
          password: anyNamed('password'),
          role: anyNamed('role'),
        ),
      ).thenAnswer((_) async {});

      await usecase.execute(
        name: 'Ana Gerente',
        username: 'ana.gerente',
        password: 'senha123',
        role: 'manager',
      );

      verify(
        mockRepo.createEmployee(
          name: 'Ana Gerente',
          email: 'ana.gerente@empresa.com',
          password: 'senha123',
          role: 'manager',
        ),
      ).called(1);
    });
  });
}