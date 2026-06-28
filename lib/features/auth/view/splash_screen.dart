import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ponto_eletronico/app/router/app_routes.dart';
import 'package:ponto_eletronico/core/constants/firestore_constants.dart';
import 'package:ponto_eletronico/data/datasources/firebase_auth_datasource.dart';
import 'package:ponto_eletronico/data/datasources/firestore_user_datasource.dart';
import 'package:ponto_eletronico/features/auth/view/first_setup_screen.dart';
import 'package:ponto_eletronico/shared/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuthDatasource();

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // ── 1. Sistema vazio? → primeiro acesso ─────────────────────────────
    final hasUsers = await _hasAnyUser();
    if (!hasUsers) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FirstSetupScreen()),
      );
      return;
    }

    // ── 2. Aguarda o Firebase Auth restaurar a sessão persistida ─────────
    // authStateReady usa authStateChanges().first, que espera o SDK
    // terminar de ler o token salvo localmente antes de retornar.
    // Isso evita o race condition de currentUser retornar null
    // enquanto o SDK ainda inicializa.
    final user = await _auth.authStateReady;

    if (!mounted) return;

    if (user == null) {
      // Sem sessão → login
      _go(AppRoutes.login);
      return;
    }

    // ── 3. Sessão restaurada → redireciona pelo role ──────────────────────
    final role = await FirestoreUserDatasource().getRole(user.uid);

    if (!mounted) return;

    if (role == 'manager') {
      _go(AppRoutes.manager);
    } else if (kIsWeb) {
      // Funcionário tentando acessar via web → bloqueia
      await _auth.signOut();
      _go(AppRoutes.login);
    } else {
      _go(AppRoutes.employee);
    }
  }

  Future<bool> _hasAnyUser() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestoreConstants.users)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  void _go(String route) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: AppTheme.background(context),
        child: Stack(
        
          fit: StackFit.expand,
          children: [
            Image(
              image: isDark
                  ? const AssetImage('assets/images/logo_web_dark.png')
                  : const AssetImage('assets/images/logo_web.png'),
              fit: BoxFit.contain,
            ),
            const Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
