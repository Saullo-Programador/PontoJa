import 'package:flutter/material.dart';

/// Exibe [mobile] em telas < 800 px e [desktop] acima disso.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) =>
          constraints.maxWidth < 800 ? mobile : desktop,
    );
  }
}