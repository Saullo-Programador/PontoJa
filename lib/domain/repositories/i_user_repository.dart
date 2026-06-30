import 'package:ponto_eletronico/domain/entities/user_entity.dart';

abstract class IUserRepository {
  Future<UserEntity> getUser(String uid);
  Future<String> getRole(String uid);
  Future<List<UserEntity>> getAllEmployees();
  Future<void> createUser({
    required String name,
    required String username,
    required String password,
    required String role,
  });
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String uid);
}