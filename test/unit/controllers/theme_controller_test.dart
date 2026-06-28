import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ponto_eletronico/shared/theme/theme_controller.dart';

void main() {
  setUp(() {
    // Reseta o SharedPreferences antes de cada teste
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeController', () {
    test('inicia com ThemeMode.system por padrão', () async {
      final ctrl = ThemeController();
      // aguarda o _load() completar
      await Future.delayed(Duration.zero);
      expect(ctrl.themeMode, equals(ThemeMode.system));
    });

    test('toggle alterna de system para dark', () async {
      final ctrl = ThemeController();
      await Future.delayed(Duration.zero);

      await ctrl.toggle();
      // system → dark (pois não é dark ainda)
      expect(ctrl.isDark, isTrue);
    });

    test('toggle alterna de dark para light', () async {
      final ctrl = ThemeController();
      await Future.delayed(Duration.zero);
      await ctrl.setTheme(ThemeMode.dark);

      await ctrl.toggle();

      expect(ctrl.isLight, isTrue);
    });

    test('setTheme persiste a escolha', () async {
      final ctrl = ThemeController();
      await Future.delayed(Duration.zero);

      await ctrl.setTheme(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));
    });

    test('carrega tema salvo ao inicializar', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

      final ctrl = ThemeController();
      await Future.delayed(Duration.zero);

      expect(ctrl.isDark, isTrue);
    });

    test('setTheme não notifica se o modo não mudou', () async {
      final ctrl = ThemeController();
      await Future.delayed(Duration.zero);
      await ctrl.setTheme(ThemeMode.dark);

      var notified = false;
      ctrl.addListener(() => notified = true);

      await ctrl.setTheme(ThemeMode.dark); // mesmo modo

      expect(notified, isFalse);
    });
  });
}