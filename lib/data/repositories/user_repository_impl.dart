import 'package:firebase_auth/firebase_auth.dart';
import 'package:ponto_eletronico/data/datasources/firestore_user_datasource.dart';
import 'package:ponto_eletronico/data/models/user_model.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final FirestoreUserDatasource _datasource;

  UserRepositoryImpl(this._datasource);

  @override
  Future<UserEntity> getUser(String uid) => _datasource.getUser(uid);

  @override
  Future<String> getRole(String uid) => _datasource.getRole(uid);

  @override
  Future<List<UserEntity>> getAllEmployees() => _datasource.getAllEmployees();

  @override
  Future<void> updateUser(UserEntity user) =>
      _datasource.saveUser(UserModel.fromEntity(user));

  @override
  Future<void> deleteUser(String uid) =>
      _datasource.deleteUser(uid);

  @override
  Future<void> createUser({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    // Gera o e-mail interno a partir do username
    final email = UserEntity.usernameToEmail(username);

    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _datasource.saveUser(UserModel(
      uid:      cred.user!.uid,
      name:     name,
      email:    email,
      username: username.trim().toLowerCase(),
      role:     role,
    ));
  }
}