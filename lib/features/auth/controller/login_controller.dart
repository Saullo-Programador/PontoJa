import 'package:flutter/foundation.dart';
import 'package:ponto_eletronico/core/exceptions/app_exception.dart';
import 'package:ponto_eletronico/data/repositories/auth_repository_impl.dart';
import 'package:ponto_eletronico/data/repositories/user_repository_impl.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';

enum LoginStatus { idle, loading, success, error }

class LoginController extends ChangeNotifier {
  final AuthRepositoryImpl _authRepo;
  final UserRepositoryImpl _userRepo;

  LoginController(this._authRepo, this._userRepo);

  LoginStatus _status = LoginStatus.idle;
  String _errorMessage = '';
  String _role = '';

  LoginStatus get status       => _status;
  String get errorMessage      => _errorMessage;
  String get role              => _role;

  /// Aceita tanto username (ex: "joao.silva") quanto e-mail completo.
  /// Se não contiver "@", trata como username e converte para e-mail interno.
  Future<void> login(String usernameOrEmail, String password) async {
    _status = LoginStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Resolve o e-mail real
      final email = usernameOrEmail.contains('@')
          ? usernameOrEmail.trim()
          : UserEntity.usernameToEmail(usernameOrEmail);

      final cred = await _authRepo.login(email, password);

      // Web → só gerente pode acessar
      if (kIsWeb) {
        final r = await _userRepo.getRole(cred.user!.uid);
        if (r != 'manager') {
          await _authRepo.logout();
          throw const PermissionException('Acesso web exclusivo para gerentes.');
        }
        _role = r;
      } else {
        _role = await _userRepo.getRole(cred.user!.uid);
      }

      _status = LoginStatus.success;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _status = LoginStatus.error;
    } catch (_) {
      _errorMessage = 'Usuário ou senha incorretos.';
      _status = LoginStatus.error;
    }

    notifyListeners();
  }
}