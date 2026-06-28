import 'package:ponto_eletronico/domain/entities/user_entity.dart';

abstract class IUserRepository {
  Future<UserEntity> getUser(String userId);
  Future<String> getRole(String userId);
  Future<List<UserEntity>> getAllEmployees();
  Future<void> deleteEmployee(String userId);
  Future<void> createEmployee({
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<void> updateUser(UserEntity user);
}