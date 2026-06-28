import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/usecases/register_point_usecase.dart';
import 'package:ponto_eletronico/features/employee/controller/employee_home_controller.dart';
import 'package:ponto_eletronico/features/employee/view/employee_home_screen.dart';
import 'package:ponto_eletronico/shared/theme/app_theme.dart';
import 'package:ponto_eletronico/shared/theme/theme_controller.dart';

import '../mocks.mocks.dart';

Widget _buildApp(EmployeeHomeController ctrl) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider<EmployeeHomeController>.value(value: ctrl),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const EmployeeHomeScreen(),
    ),
  );
}

void main() {
  late MockITimeRecordRepository mockRepo;
  late RegisterPointUsecase usecase;
  late EmployeeHomeController controller;

  setUp(() {
    mockRepo = MockITimeRecordRepository();
    usecase = RegisterPointUsecase(mockRepo);
    controller = EmployeeHomeController(usecase);
  });

  group('EmployeeHomeScreen', () {
    testWidgets('exibe botão "Registrar Entrada" quando sem registro', (tester) async {
      when(mockRepo.getTodayRecord(any)).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildApp(controller));
      await tester.pump();

      expect(find.text('Registrar Entrada'), findsOneWidget);
      expect(find.text('Registrar Saída'), findsNothing);
    });

    testWidgets('exibe botão "Registrar Saída" quando há entrada sem saída',
        (tester) async {
      final record = TimeRecordEntity(
        id: 'r1',
        userId: 'u1',
        date: DateTime.now(),
        entry: DateTime.now().subtract(const Duration(hours: 4)),
      );
      when(mockRepo.getTodayRecord(any)).thenAnswer((_) async => record);

      await controller.loadTodayRecord('u1');
      await tester.pumpWidget(_buildApp(controller));
      await tester.pump();

      expect(find.text('Registrar Saída'), findsOneWidget);
      expect(find.text('Registrar Entrada'), findsNothing);
    });

    testWidgets('exibe badge "Ponto completo" quando entrada e saída registradas',
        (tester) async {
      final record = TimeRecordEntity(
        id: 'r1',
        userId: 'u1',
        date: DateTime.now(),
        entry: DateTime.now().subtract(const Duration(hours: 8)),
        exit: DateTime.now(),
      );
      when(mockRepo.getTodayRecord(any)).thenAnswer((_) async => record);

      await controller.loadTodayRecord('u1');
      await tester.pumpWidget(_buildApp(controller));
      await tester.pump();

      expect(find.text('Ponto completo hoje!'), findsOneWidget);
      expect(find.text('Registrar Entrada'), findsNothing);
      expect(find.text('Registrar Saída'), findsNothing);
    });

    testWidgets('exibe cards de Entrada e Saída na tela', (tester) async {
      when(mockRepo.getTodayRecord(any)).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildApp(controller));
      await tester.pump();

      expect(find.text('Entrada'), findsOneWidget);
      expect(find.text('Saída'), findsOneWidget);
    });
  });
}