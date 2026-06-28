import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthRepository {
  Future<UserCredential> login(String email, String password);
  Future<void> logout();
  User? get currentUser;
}