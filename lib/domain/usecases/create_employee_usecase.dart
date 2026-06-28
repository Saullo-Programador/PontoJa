import 'package:ponto_eletronico/domain/repositories/i_user_repository.dart';

class CreateEmployeeUsecase {
  final IUserRepository _repository;

  CreateEmployeeUsecase(this._repository);

  Future<void> execute({
    required String name,
    required String email,
    required String password,
    String role = 'employee'
  }) =>
      _repository.createEmployee(
        name: name,
        email: email,
        password: password,
        role: role
      );
}