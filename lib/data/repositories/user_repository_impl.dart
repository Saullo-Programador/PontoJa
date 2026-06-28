import 'package:firebase_auth/firebase_auth.dart';
import 'package:ponto_eletronico/data/datasources/firestore_user_datasource.dart';
import 'package:ponto_eletronico/data/models/user_model.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';
import 'package:ponto_eletronico/domain/repositories/i_user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final FirestoreUserDatasource _dataSource;
  UserRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> getUser(String uid) => _dataSource.getUser(uid);

  @override
  Future<String> getRole(String uid) => _dataSource.getRole(uid);

  @override
  Future<List<UserEntity>> getAllEmployees() => _dataSource.getAllEmployees();

  @override
  Future<void> updateUser(UserEntity user) => _dataSource.saveUser(UserModel.fromEntity(user));

  @override
  Future<void> deleteEmployee(String uid) => _dataSource.deleteEmployee(uid);

  @override
  Future<void> createEmployee({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final tempApp = FirebaseAuth.instance;
    final cred = await tempApp.createUserWithEmailAndPassword(email: email, password: password);

    await _dataSource.saveUser(UserModel(
      uid: cred.user!.uid,
      name: name,
      email: email,
      role: role,
    ));
  }
}