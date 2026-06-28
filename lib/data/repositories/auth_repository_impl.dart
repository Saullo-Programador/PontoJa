import 'package:firebase_auth/firebase_auth.dart';
import 'package:ponto_eletronico/core/exceptions/app_exception.dart';
import 'package:ponto_eletronico/data/datasources/firebase_auth_datasource.dart';
import 'package:ponto_eletronico/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _datasource.signIn(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> logout() => _datasource.signOut();

  @override
  User? get currentUser => _datasource.currentUser;

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro ao realizar login.';
    }
  }
}