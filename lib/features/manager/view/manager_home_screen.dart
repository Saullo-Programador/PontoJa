import 'package:flutter/material.dart';
import 'package:ponto_eletronico/features/manager/view/delete_point_dialog.dart';
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

  void _showWorkplaceConfig() {
    Navigator.pushNamed(context, AppRoutes.workplace);
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Gerando relatório...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final result = await ctrl.exportExcelReport(
      month: now.month,
      year: now.year,
    );

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
        if (value == 'location') _showWorkplaceConfig();
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
          value: 'location',
          child: ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Local de trabalho'),
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
    final records = ctrl.monthlyRecords
        .where((r) => r.userId == emp.uid)
        .toList();

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
          builder: (_) =>
              EditPointDialog(record: record, onSave: ctrl.editPoint),
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
      return _statusChip(
        context,
        label: 'Ausente',
        icon: Icons.remove_circle_outline,
        bg: Theme.of(context).colorScheme.surfaceContainerHighest,
        fg: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    if (record!.hasExit) {
      return _statusChip(
        context,
        label: 'Finalizado',
        icon: Icons.check_circle_outline,
        bg: isDark ? const Color(0xFF1B3A2A) : Colors.green.shade100,
        fg: isDark ? const Color(0xFF81C995) : Colors.green.shade800,
      );
    }

    if (record!.isOnBreak) {
      return _statusChip(
        context,
        label: 'Em intervalo',
        icon: Icons.coffee_outlined,
        bg: isDark ? const Color(0xFF1A2A3A) : Colors.blue.shade100,
        fg: isDark ? const Color(0xFF81C9E9) : Colors.blue.shade800,
      );
    }

    return _statusChip(
      context,
      label: 'Em expediente',
      icon: Icons.work_outline,
      bg: isDark ? const Color(0xFF3A2A00) : Colors.orange.shade100,
      fg: isDark ? const Color(0xFFFFB74D) : Colors.orange.shade800,
    );
  }

  Widget _statusChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: fg),
      label: Text(label),
      backgroundColor: bg,
      labelStyle: TextStyle(
        color: fg,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                          leading: Icon(
                            Icons.access_time,
                            color: colorScheme.primary,
                          ),
                          title: Text(r.date.toDateDisplay()),
                          subtitle: Text(
                            'Entrada: ${r.entry.toDisplay()}  '
                            'Saída: ${r.exit?.toDisplay() ?? 'pendente'}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: colorScheme.primary,
                            ),
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

class _TodayPointsTab extends StatefulWidget {
  final ManagerHomeController ctrl;
  const _TodayPointsTab({required this.ctrl});

  @override
  State<_TodayPointsTab> createState() => _TodayPointsTabState();
}

class _TodayPointsTabState extends State<_TodayPointsTab> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final ctrl = widget.ctrl;
    final picked = await showDatePicker(
      context: context,
      initialDate: ctrl.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      ctrl.selectDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ctrl = widget.ctrl;
    final records = ctrl.filteredTodayRecords;
    final isToday = ctrl.selectedDate == null;

    return Column(
      children: [
        // ── Barra de busca + data ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: ctrl.setNameQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar funcionário...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtrl.clear();
                              ctrl.setNameQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: isToday ? colorScheme.primary : colorScheme.onSecondaryContainer,
                ),
                label: Text(
                  isToday ? 'Hoje' : ctrl.selectedDate!.toDateDisplay(),
                ),
                backgroundColor: isToday
                    ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : colorScheme.secondaryContainer,
                onPressed: () => _pickDate(context),
              ),
              if (!isToday)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Voltar para hoje',
                  onPressed: () => ctrl.selectDate(null),
                ),
            ],
          ),
        ),

        // ── Lista de registros ──────────────────────────────────────────
        Expanded(
          child: records.isEmpty
              ? Center(
                  child: Text(
                    ctrl.nameQuery.isNotEmpty
                        ? 'Nenhum funcionário encontrado.'
                        : isToday
                            ? 'Nenhum registro hoje.'
                            : 'Nenhum registro nesta data.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: records.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: colorScheme.outlineVariant),
                  itemBuilder: (_, i) {
                    final r = records[i];
                    final emp = ctrl.employees
                        .where((e) => e.uid == r.userId)
                        .firstOrNull;

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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined,
                                color: colorScheme.primary),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => EditPointDialog(
                                  record: r, onSave: ctrl.editPoint),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outlined,
                                color: Colors.red),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => DeletePointDialog(
                                  record: r, onDelete: ctrl.deletePoint),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
