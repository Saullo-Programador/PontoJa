import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ponto_eletronico/app/di/injection.dart';
import 'package:ponto_eletronico/app/router/app_pages.dart';
import 'package:ponto_eletronico/app/router/app_routes.dart';
import 'package:ponto_eletronico/firebase_options.dart';
import 'package:ponto_eletronico/shared/theme/app_theme.dart';
import 'package:ponto_eletronico/shared/theme/theme_controller.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ...appProviders,
      ],
      child: Consumer<ThemeController>(
        builder: (_, themeCtrl, __) => MaterialApp(
          title: 'Ponto Eletrônico',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeCtrl.themeMode,
          initialRoute: AppRoutes.splash,
          routes: appRoutes,
          builder: (context, child) => _AuthGuard(child: child!),
        ),
      ),
    );
  }
}

/// Ouve o stream de autenticação do Firebase.
/// Se o usuário sair (ou o token expirar), joga para /login de qualquer tela.
class _AuthGuard extends StatefulWidget {
  final Widget child;
  const _AuthGuard({required this.child});

  @override
  State<_AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<_AuthGuard> {
  // Rotas que podem ser acessadas sem sessão (não redireciona nelas)
  static const _publicRoutes = {AppRoutes.splash, AppRoutes.login};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Ainda inicializando → não faz nada
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.child;
        }

        final user = snapshot.data;
        final currentRoute = ModalRoute.of(context)?.settings.name;
        final isPublic = _publicRoutes.contains(currentRoute);

        // Sessão encerrada fora de rota pública → vai para login
        if (user == null && !isPublic) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
          });
        }

        return widget.child;
      },
    );
  }
}
