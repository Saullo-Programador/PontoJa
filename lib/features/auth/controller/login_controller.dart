import 'package:flutter/foundation.dart';
import 'package:ponto_eletronico/core/exceptions/app_exception.dart';
import 'package:ponto_eletronico/data/repositories/auth_repository_impl.dart';
import 'package:ponto_eletronico/data/repositories/user_repository_impl.dart';

enum LoginStatus { idle, loading, success, error }

class LoginController extends ChangeNotifier {
  final AuthRepositoryImpl _authRepo;
  final UserRepositoryImpl _userRepo;

  LoginController(this._authRepo, this._userRepo);

  LoginStatus _status = LoginStatus.idle;
  String _errorMessage = '';
  String _role = '';

  LoginStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get role => _role;

  Future<void> login(String email, String password) async {
    _status = LoginStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final cred = await _authRepo.login(email, password);

      // Web → só gerente pode acessar
      if (kIsWeb) {
        final role = await _userRepo.getRole(cred.user!.uid);
        if (role != 'manager') {
          await _authRepo.logout();
          throw const PermissionException(
              'Acesso web exclusivo para gerentes.');
        }
        _role = role;
      } else {
        _role = await _userRepo.getRole(cred.user!.uid);
      }

      _status = LoginStatus.success;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _status = LoginStatus.error;
    } catch (_) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
      _status = LoginStatus.error;
    }

    notifyListeners();
  }
}