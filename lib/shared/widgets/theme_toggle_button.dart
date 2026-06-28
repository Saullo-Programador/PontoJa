import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ponto_eletronico/shared/theme/theme_controller.dart';

/// Botão de alternância claro/escuro para usar no AppBar.
/// Troca o ícone automaticamente conforme o tema atual.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ThemeController>();
    return IconButton(
      icon: Icon(ctrl.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      tooltip: ctrl.isDark ? 'Tema claro' : 'Tema escuro',
      onPressed: ctrl.toggle,
    );
  }
}