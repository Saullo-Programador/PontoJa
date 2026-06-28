import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<UserCredential> createUser(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  /// Snapshot síncrono do cache local.
  /// Pode ser null por um breve instante na inicialização do SDK —
  /// prefira [authStateReady] ou o stream [authStateChanges] para navegação.
  User? get currentUser => _auth.currentUser;
 
  /// Stream reativo: emite null (deslogado) ou User (logado) sempre que
  /// o estado de autenticação muda. Persiste entre sessões automaticamente
  /// pois o Firebase Auth salva o token no storage da plataforma.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
 
  /// Aguarda o Firebase Auth restaurar o estado persistido antes de
  /// retornar. Garante que currentUser não seja null por causa de race condition.
  Future<User?> get authStateReady async {
    return _auth.authStateChanges().first;
  }
}