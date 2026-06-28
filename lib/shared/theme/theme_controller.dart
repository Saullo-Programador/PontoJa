import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia o ThemeMode do app e persiste a escolha do usuário.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isSystem => _themeMode == ThemeMode.system;

  ThemeController() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    _themeMode = switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark, // padrão
    };

    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> toggle() async {
    await setTheme(
      _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }
}