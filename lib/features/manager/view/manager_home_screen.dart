import 'package:flutter/material.dart';
import 'package:ponto_eletronico/shared/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';
import 'package:ponto_eletronico/app/router/app_routes.dart';
import 'package:ponto_eletronico/core/utils/date_utils.dart';
import 'package:ponto_eletronico/data/datasources/firebase_auth_datasource.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';
import 'package:ponto_eletronico/features/manager/controller/manager_home_controller.dart';
import 'package:ponto_eletronico/features/manager/view/create_employee_dialog.dart';
import 'package:ponto_eletronico/features/manager/view/edit_point_dialog.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _authDs = FirebaseAuthDatasource();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ManagerHomeController>().loadAll(),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authDs.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _showCreateEmployee() {
    showDialog(
      context: context,
      builder: (_) => CreateEmployeeDialog(
        onSave: (name, email, pass, role) =>
            context.read<ManagerHomeController>().createEmployee(
              name: name,
              email: email,
              password: pass,
              role: role,
            ),
      ),
    );
  }

  Future<void> _exportExcel() async {
    final ctrl = context.read<ManagerHomeController>();
    final now = DateTime.now();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Gerando relatório...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final result = await ctrl.exportExcelReport(month: now.month, year: now.year);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? (result.path != null
                  ? 'Relatório salvo em:\n${result.path}'
                  : 'Download iniciado com sucesso!')
              : 'Erro: ${result.errorMessage}',
        ),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Gerenciamento',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const ThemeToggleButton(),
                _buildMobileActions(context),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Funcionários', icon: Icon(Icons.people_outline)),
            Tab(text: 'Ponto do dia', icon: Icon(Icons.today_outlined)),
          ],
        ),
      ),
      body: Consumer<ManagerHomeController>(
        builder: (_, ctrl, __) {
          if (ctrl.status == ManagerStatus.loading && ctrl.employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _EmployeeListTab(ctrl: ctrl),
              _TodayPointsTab(ctrl: ctrl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return PopupMenuButton<String>(
      borderRadius: BorderRadius.circular(12),
      iconColor: Colors.white,
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'add') _showCreateEmployee();
        if (value == 'excel') _exportExcel();
        if (value == 'logout') _logout();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'add',
          child: ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Novo funcionário'),
          ),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: ListTile(
            leading: Icon(Icons.table_chart),
            title: Text('Exportar Excel'),
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sair'),
          ),
        ),
      ],
    );
  }
}

// ── Aba: lista de funcionários ─────────────────────────────────────────────

class _EmployeeListTab extends StatelessWidget {
  final ManagerHomeController ctrl;
  const _EmployeeListTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.employees.isEmpty) {
      return const Center(child: Text('Nenhum funcionário cadastrado.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ctrl.employees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final emp = ctrl.employees[i];
        final todayRecord = ctrl.getTodayRecordFor(emp.uid);

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Text(emp.name[0].toUpperCase()),
            ),
            title: Text(
              emp.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(emp.email),
            trailing: _PontoBadge(record: todayRecord),
            onTap: () => _showMonthlyPoints(context, emp, ctrl),
          ),
        );
      },
    );
  }

  void _showMonthlyPoints(
    BuildContext context,
    UserEntity emp,
    ManagerHomeController ctrl,
  ) {
    final records = ctrl.monthlyRecords.where((r) => r.userId == emp.uid).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MonthlyPointsSheet(
        employee: emp,
        records: records,
        onEdit: (record) => showDialog(
          context: context,
          builder: (_) => EditPointDialog(record: record, onSave: ctrl.editPoint),
        ),
      ),
    );
  }
}

// ── Badge de status do ponto ───────────────────────────────────────────────

class _PontoBadge extends StatelessWidget {
  final TimeRecordEntity? record;
  const _PontoBadge({this.record});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (record == null) {
      return Chip(
        label: const Text('Sem registro'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      );
    }

    if (record!.hasExit) {
      return Chip(
        label: const Text('Completo'),
        backgroundColor: isDark ? const Color(0xFF1B3A2A) : Colors.green.shade100,
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF81C995) : Colors.green.shade800,
          fontSize: 12,
        ),
      );
    }

    return Chip(
      label: const Text('Só entrada'),
      backgroundColor: isDark ? const Color(0xFF3A2A00) : Colors.orange.shade100,
      labelStyle: TextStyle(
        color: isDark ? const Color(0xFFFFB74D) : Colors.orange.shade800,
        fontSize: 12,
      ),
    );
  }
}

// ── Bottom sheet: pontos mensais ───────────────────────────────────────────

class _MonthlyPointsSheet extends StatelessWidget {
  final UserEntity employee;
  final List<TimeRecordEntity> records;
  final void Function(TimeRecordEntity) onEdit;

  const _MonthlyPointsSheet({
    required this.employee,
    required this.records,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scroll) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              employee.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              'Registros do mês',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum registro este mês.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      controller: scroll,
                      itemCount: records.length,
                      itemBuilder: (_, i) {
                        final r = records[i];
                        return ListTile(
                          leading: Icon(Icons.access_time, color: colorScheme.primary),
                          title: Text(r.date.toDateDisplay()),
                          subtitle: Text(
                            'Entrada: ${r.entry.toDisplay()}  '
                            'Saída: ${r.exit?.toDisplay() ?? 'pendente'}',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                            onPressed: () => onEdit(r),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aba: ponto do dia ──────────────────────────────────────────────────────

class _TodayPointsTab extends StatelessWidget {
  final ManagerHomeController ctrl;
  const _TodayPointsTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final records = ctrl.todayRecords;

    if (records.isEmpty) {
      return Center(
        child: Text(
          'Nenhum registro hoje.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => Divider(color: colorScheme.outlineVariant),
      itemBuilder: (_, i) {
        final r = records[i];
        final emp = ctrl.employees.where((e) => e.uid == r.userId).firstOrNull;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: Text(emp?.name[0].toUpperCase() ?? '?'),
          ),
          title: Text(emp?.name ?? r.userId),
          subtitle: Text(
            'Entrada: ${r.entry.toDisplay()}  '
            'Saída: ${r.exit?.toDisplay() ?? 'pendente'}',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => EditPointDialog(record: r, onSave: ctrl.editPoint),
            ),
          ),
        );
      },
    );
  }
}