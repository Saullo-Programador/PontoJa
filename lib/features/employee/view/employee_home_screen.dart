import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ponto_eletronico/app/router/app_routes.dart';
import 'package:ponto_eletronico/core/utils/date_utils.dart';
import 'package:ponto_eletronico/data/datasources/firebase_auth_datasource.dart';
import 'package:ponto_eletronico/features/employee/controller/employee_home_controller.dart';
import 'package:ponto_eletronico/shared/widgets/theme_toggle_button.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final _authDs = FirebaseAuthDatasource();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = _authDs.currentUser?.uid;
      if (uid != null) {
        context.read<EmployeeHomeController>().loadTodayRecord(uid);
      }
    });
  }

  Future<void> _logout() async {
    await _authDs.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _confirmAndPunch(String uid, bool isEntry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isEntry ? Icons.login_rounded : Icons.logout_rounded,
              color: isEntry ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 10),
            Text(isEntry ? 'Registrar Entrada' : 'Registrar Saída'),
          ],
        ),
        content: Text(
          isEntry
              ? 'Deseja confirmar o registro de entrada agora?'
              : 'Deseja confirmar o registro de saída agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isEntry ? Colors.green : Colors.orange,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<EmployeeHomeController>().registerPoint(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<EmployeeHomeController>();
    final uid = _authDs.currentUser?.uid ?? '';
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determina estado atual do botão
    final isEntry = !ctrl.hasEntry;
    final punchColor = isEntry ? Colors.green : Colors.orange;
    final punchComplete = ctrl.hasEntry && ctrl.hasExit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Ponto'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Cabeçalho: data + saudação ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          now.toDateDisplay(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          _greeting(),
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Cards entrada / saída ───────────────────────────────────
              _PunchStatusRow(ctrl: ctrl, isDark: isDark),

              const Spacer(),

              // ── Botão circular central ─────────────────────────────────
              Center(
                child: ctrl.status == PointStatus.loading
                    ? const SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : punchComplete
                        ? _CompleteBadge(isDark: isDark)
                        : _PunchButton(
                            isEntry: isEntry,
                            color: punchColor,
                            onTap: () => _confirmAndPunch(uid, isEntry),
                          ),
              ),

              const Spacer(),

              // ── Erro ───────────────────────────────────────────────────
              if (ctrl.status == PointStatus.error)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    ctrl.errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia! 👋';
    if (h < 18) return 'Boa tarde! 👋';
    return 'Boa noite! 👋';
  }
}

// ── Botão circular ─────────────────────────────────────────────────────────

class _PunchButton extends StatelessWidget {
  final bool isEntry;
  final Color color;
  final VoidCallback onTap;

  const _PunchButton({
    required this.isEntry,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEntry ? Icons.login_rounded : Icons.logout_rounded,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              isEntry ? 'Entrada' : 'Saída',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Toque para registrar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cards entrada / saída ──────────────────────────────────────────────────

class _PunchStatusRow extends StatelessWidget {
  final EmployeeHomeController ctrl;
  final bool isDark;

  const _PunchStatusRow({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PunchCard(
            label: 'Entrada',
            time: ctrl.todayRecord?.entry.toDisplay() ?? '—',
            done: ctrl.hasEntry,
            icon: Icons.login_rounded,
            color: Colors.green,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PunchCard(
            label: 'Saída',
            time: ctrl.todayRecord?.exit?.toDisplay() ?? '—',
            done: ctrl.hasExit,
            icon: Icons.logout_rounded,
            color: Colors.orange,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _PunchCard extends StatelessWidget {
  final String label;
  final String time;
  final bool done;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _PunchCard({
    required this.label,
    required this.time,
    required this.done,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = done
        ? color
        : Theme.of(context).colorScheme.outlineVariant;

    final iconColor = done
        ? color
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done
            ? color.withOpacity(isDark ? 0.12 : 0.07)
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: done ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: done ? color : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge ponto completo ───────────────────────────────────────────────────

class _CompleteBadge extends StatelessWidget {
  final bool isDark;
  const _CompleteBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF1B3A2A) : Colors.green.shade50,
        border: Border.all(
          color: isDark ? const Color(0xFF81C995) : Colors.green,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: isDark ? const Color(0xFF81C995) : Colors.green,
            size: 52,
          ),
          const SizedBox(height: 8),
          Text(
            'Completo!',
            style: TextStyle(
              color: isDark ? const Color(0xFF81C995) : Colors.green.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bom trabalho hoje',
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF81C995).withOpacity(0.7)
                  : Colors.green.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}