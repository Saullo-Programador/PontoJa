import 'package:ponto_eletronico/domain/repositories/i_user_repository.dart';

class DeleteEmployeeUsecase {
  final IUserRepository _repository;
  DeleteEmployeeUsecase(this._repository);

  Future<void> execute(String uid) => _repository.deleteUser(uid);
}