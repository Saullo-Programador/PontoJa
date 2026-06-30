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
import 'package:flutter_localizations/flutter_localizations.dart';

/// Chave global do Navigator — permite navegar de qualquer lugar
/// (inclusive de dentro do listener de auth) sem depender de um
/// BuildContext específico de uma rota.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Rotas que podem ser acessadas sem sessão.
  static const _publicRoutes = {AppRoutes.splash, AppRoutes.login};

  bool _firstEventSkipped = false;

  @override
  void initState() {
    super.initState();
    // Escuta o estado de auth, mas ignora o primeiro evento emitido —
    // ele só representa o estado inicial restaurado do disco, que é
    // tratado pela própria SplashScreen. Reagir a ele aqui também
    // causaria a corrida de navegação observada no reload da web.
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    if (!_firstEventSkipped) {
      _firstEventSkipped = true;
      return;
    }

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    final currentRoute = ModalRoute.of(nav.context)?.settings.name;
    final isPublic = _publicRoutes.contains(currentRoute);

    if (user == null && !isPublic) {
      nav.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ...appProviders,
      ],
      child: Consumer<ThemeController>(
        builder: (_, themeCtrl, __) => MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR'), Locale('en')],
          locale: const Locale('pt', 'BR'),
          title: 'Ponto Eletrônico',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeCtrl.themeMode,
          initialRoute: AppRoutes.splash,
          routes: appRoutes,
        ),
      ),
    );
  }
}