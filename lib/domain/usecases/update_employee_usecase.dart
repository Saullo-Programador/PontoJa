import 'package:ponto_eletronico/domain/entities/user_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_user_repository.dart';

class UpdateEmployeeUsecase {
  final IUserRepository _repository;
  UpdateEmployeeUsecase(this._repository);

  Future<void> execute(UserEntity user) => _repository.updateUser(user);
}