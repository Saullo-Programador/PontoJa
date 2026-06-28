class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class PermissionException extends AppException {
  const PermissionException(super.message);
}

class DataException extends AppException {
  const DataException(super.message);
}