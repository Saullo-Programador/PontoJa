import 'package:ponto_eletronico/domain/repositories/i_user_repository.dart';

class CreateEmployeeUsecase {
  final IUserRepository _repository;

  CreateEmployeeUsecase(this._repository);

  Future<void> execute({
    required String name,
    required String username,
    required String password,
    String role = 'employee',
  }) =>
      _repository.createUser(
        name:     name,
        username: username,
        password: password,
        role:     role,
      );
}