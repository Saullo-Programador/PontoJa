import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ponto_eletronico/app/router/app_routes.dart';
import 'package:ponto_eletronico/core/utils/date_utils.dart';
import 'package:ponto_eletronico/data/datasources/firebase_auth_datasource.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
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

  Future<void> _refresh() async {
    final uid = _authDs.currentUser?.uid;

    if (uid != null) {
      await context.read<EmployeeHomeController>().loadTodayRecord(uid);
    }
  }

  Future<void> _confirmAndPunch(String uid, PunchStep step) async {
    final info = _stepInfo(step);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(info.icon, color: info.color),
            const SizedBox(width: 10),
            Text(info.label),
          ],
        ),
        content: Text(info.question),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: info.color),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final completedStep = await context
        .read<EmployeeHomeController>()
        .registerPoint(uid);

    if (!mounted) return;
    _showFeedback(completedStep);
  }

  void _showFeedback(PunchStep completed) {
    final msgs = {
      PunchStep.breakStart: (
        'Intervalo iniciado ☕',
        'Bom descanso.',
        Colors.blue,
      ),

      PunchStep.breakEnd: (
        'Retorno registrado 💪',
        'Bom trabalho.',
        Colors.purple,
      ),

      PunchStep.exit: ('Saída registrada 👋', 'Até amanhã.', Colors.orange),

      PunchStep.done: ('Ponto concluído', '', Colors.green),
    };

    final (title, subtitle, color) =
        msgs[completed] ?? ('Ponto registrado!', '', Colors.green);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<EmployeeHomeController>();
    final uid = _authDs.currentUser?.uid ?? '';
    final now = DateTime.now();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Cabeçalho ───────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: cs.primary,
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
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              _greeting(),
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Timeline de status ───────────────────────────────────────
                  _TimelineRow(record: ctrl.todayRecord, isDark: isDark),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),

                  // ── Botão central / badge completo ───────────────────────────
                  Center(
                    child: ctrl.status == PointStatus.loading
                        ? const SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : ctrl.isComplete
                        ? _CompleteBadge(isDark: isDark)
                        : !ctrl.hasEntry
                        // ── Botão único: ENTRADA ─────────────────────
                        ? _PunchButton(
                            step: PunchStep.breakStart,
                            onTap: () =>
                                _confirmAndPunch(uid, PunchStep.breakStart),
                          )
                        // ── Dois botões: intervalo + saída ───────────
                        : _DoubleButtons(
                            step: ctrl.nextStep,
                            isOnBreak: ctrl.isOnBreak,
                            breakCount: ctrl.breakCount,
                            onTap: (s) => _confirmAndPunch(uid, s),
                          ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),

                  // ── Erro ─────────────────────────────────────────────────────
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

  _StepInfo _stepInfo(PunchStep step) => switch (step) {
    PunchStep.entry => _StepInfo(
      icon: Icons.login_rounded,
      color: Colors.green,
      label: 'Registrar Entrada',
      question: 'Deseja registrar a entrada?',
    ),
    PunchStep.breakStart => _StepInfo(
      icon: Icons.login_rounded,
      color: Colors.green,
      label: 'Iniciar Intervalo',
      question: 'Deseja iniciar o intervalo?',
    ),
    PunchStep.breakEnd => _StepInfo(
      icon: Icons.coffee_rounded,
      color: Colors.blue,
      label: 'Retornar do Intervalo',
      question: 'Deseja registrar o retorno?',
    ),
    PunchStep.exit => _StepInfo(
      icon: Icons.play_circle_outline_rounded,
      color: Colors.purple,
      label: 'Registrar Saída',
      question: 'Deseja registrar a saída?',
    ),
    PunchStep.done => _StepInfo(
      icon: Icons.logout_rounded,
      color: Colors.orange,
      label: 'Registrar Saída',
      question: 'Deseja confirmar o registro de saída?',
    ),
  };
}

// ── Data class auxiliar ────────────────────────────────────────────────────

class _StepInfo {
  final IconData icon;
  final Color color;
  final String label;
  final String question;
  const _StepInfo({
    required this.icon,
    required this.color,
    required this.label,
    required this.question,
  });
}

// ── Timeline de status ─────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  final TimeRecordEntity? record;
  final bool isDark;

  const _TimelineRow({this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        icon: Icons.login_rounded,
        label: 'Entrada',
        time: record?.entry.toDisplay(),
        color: Colors.green,
        done: record != null,
        isDark: isDark,
      ),
      _TimelineStep(
        icon: Icons.coffee_rounded,
        label: 'Intervalo',
        time: record != null && record!.breaks.isNotEmpty
            ? record!.breaks.last.start.toDisplay()
            : null,
        color: Colors.blue,
        done: record?.hasBreakStart ?? false,
        isDark: isDark,
      ),
      _TimelineStep(
        icon: Icons.play_circle_outline_rounded,
        label: 'Retorno',
        time: record != null && record!.breaks.isNotEmpty
            ? record!.breaks.last.end?.toDisplay()
            : null,
        color: Colors.purple,
        done: record?.hasBreakEnd ?? false,
        isDark: isDark,
      ),
      _TimelineStep(
        icon: Icons.logout_rounded,
        label: 'Saída',
        time: record?.exit?.toDisplay(),
        color: Colors.orange,
        done: record?.hasExit ?? false,
        isDark: isDark,
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Expanded(child: steps[i]),
          if (i < steps.length - 1)
            Container(
              height: 2,
              width: 12,
              color: steps[i].done
                  ? steps[i].color.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
        ],
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? time;
  final Color color;
  final bool done;
  final bool isDark;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
    required this.done,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? color.withValues(alpha: isDark ? 0.2 : 0.1)
                : cs.surfaceContainerLow,
            border: Border.all(
              color: done ? color : cs.outlineVariant,
              width: done ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            color: done ? color : cs.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: done ? color : cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time ?? '—',
          style: TextStyle(
            fontSize: 10,
            color: done ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Botão único (entrada) ──────────────────────────────────────────────────

class _PunchButton extends StatelessWidget {
  final PunchStep step;
  final VoidCallback onTap;

  const _PunchButton({required this.step, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login_rounded, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text(
              'Entrada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Toque para registrar',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dois botões (intervalo + saída) ───────────────────────────────────────

class _DoubleButtons extends StatelessWidget {
  final PunchStep step;
  final bool isOnBreak;
  final int breakCount;
  final void Function(PunchStep) onTap;

  const _DoubleButtons({
    required this.step,
    required this.isOnBreak,
    required this.breakCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnBreak) {
      return _CircleButton(
        icon: Icons.play_circle_outline_rounded,
        label: 'Retornar',
        color: Colors.purple,
        size: 180,
        onTap: () => onTap(PunchStep.breakEnd),
      );
    }

    if (breakCount >= 3) {
      return _CircleButton(
        icon: Icons.logout_rounded,
        label: 'Saída',
        color: Colors.orange,
        size: 180,
        onTap: () => onTap(PunchStep.exit),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          icon: Icons.coffee_rounded,
          label: 'Intervalo',
          color: Colors.blue,
          size: 140,
          onTap: () => onTap(PunchStep.breakStart),
        ),
        const SizedBox(width: 24),
        _CircleButton(
          icon: Icons.logout_rounded,
          label: 'Saída',
          color: Colors.orange,
          size: 140,
          onTap: () => onTap(PunchStep.exit),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: size * 0.27),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
            color: Colors.green.withValues(alpha: 0.2),
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
                  ? const Color(0xFF81C995).withValues(alpha: 0.7)
                  : Colors.green.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
