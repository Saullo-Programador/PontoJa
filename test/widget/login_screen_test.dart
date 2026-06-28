import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ponto_eletronico/features/auth/controller/login_controller.dart';
import 'package:ponto_eletronico/features/auth/view/login_screen.dart';
import 'package:ponto_eletronico/shared/theme/app_theme.dart';
import 'package:ponto_eletronico/shared/theme/theme_controller.dart';

// Mock manual do LoginController para testes de widget
class MockLoginController extends Mock implements LoginController {
  @override
  LoginStatus get status => LoginStatus.idle;

  @override
  String get errorMessage => '';

  @override
  String get role => '';

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

Widget _buildTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider<LoginController>(
        create: (_) => MockLoginController(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: child,
    ),
  );
}

void main() {
  group('LoginScreen – validação do formulário', () {
    testWidgets('exibe erro ao submeter e-mail vazio', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // Toca no botão sem preencher nada
      final button = find.text('Entrar');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('E-mail obrigatório'), findsOneWidget);
    });

    testWidgets('exibe erro para e-mail inválido', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'email-invalido',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('exibe erro para senha curta', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'valido@email.com',
      );
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('não exibe erros quando formulário está válido', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'gerente@empresa.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'senha123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail obrigatório'), findsNothing);
      expect(find.text('E-mail inválido'), findsNothing);
    });
  });
}