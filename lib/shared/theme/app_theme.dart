import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppTheme {
  // ── Paleta base ─────────────────────────────────────────────────────────
  static const _primary = Color(0xFF1565C0);
  static const _secondary = Color(0xFF1E88E5);

  // Light
  static const lightBackground = Color.fromARGB(255, 244, 249, 249);

  // Dark gradient
  static const darkGradientStart = Color(0xFF0B2637);
  static const darkGradientEnd = Color(0xFF020616);

  // Dark
  static const _primaryDark = Color(0xFF90CAF9); // azul mais claro p/ contraste
  static const _secondaryDark = Color(0xFF64B5F6);
  static const _surfaceDark = Color(0xFF1E1E2E);
  static const _backgroundDark = Color(0xFF12121C);
  static const _cardDark = Color(0xFF252535);

  // ── Tema claro ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      secondary: _secondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // ── Tema escuro ──────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryDark,
      brightness: Brightness.dark,
      primary: _primaryDark,
      secondary: _secondaryDark,
      surface: _surfaceDark,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: _backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: _backgroundDark,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: _backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A4A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A4A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF9A9A)),
      ),
      hintStyle: const TextStyle(color: Color(0xFF8888AA)),
      labelStyle: const TextStyle(color: Color(0xFF8888AA)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: _cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: Color(0xFF2E2E3E)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF3A3A4A)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF2E2E3E)),
    listTileTheme: const ListTileThemeData(iconColor: _primaryDark),
    iconTheme: const IconThemeData(color: _primaryDark),
  );

  static BoxDecoration background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkGradientStart, darkGradientEnd],
        ),
      );
    }

    return const BoxDecoration(color: lightBackground);
  }
}
