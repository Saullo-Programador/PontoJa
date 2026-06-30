import 'package:flutter/material.dart';
import 'package:ponto_eletronico/core/utils/validators.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';
import 'package:ponto_eletronico/shared/widgets/custom_input.dart';

class EditEmployeeDialog extends StatefulWidget {
  final UserEntity employee;
  final Future<void> Function(UserEntity updated) onSave;
  final Future<void> Function(String uid) onDelete;

  const EditEmployeeDialog({
    super.key,
    required this.employee,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<EditEmployeeDialog> {
  final _formKey  = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _userCtrl;
  late String _role;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.employee.name);
    _userCtrl = TextEditingController(text: widget.employee.username);
    _role     = widget.employee.role;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final updated = UserEntity(
        uid:      widget.employee.uid,
        name:     _nameCtrl.text.trim(),
        username: _userCtrl.text.trim().toLowerCase(),
        email:    UserEntity.usernameToEmail(
                      _userCtrl.text.trim().toLowerCase()),
        role:     _role,
      );
      await widget.onSave(updated);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Remover funcionário'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Deseja remover '),
              TextSpan(
                text: widget.employee.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(
                text: '?\n\nEssa ação remove o funcionário do sistema. '
                    'Os registros de ponto não serão apagados.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await widget.onDelete(widget.employee.uid);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: cs.primaryContainer,
            foregroundColor: cs.onPrimaryContainer,
            child: Text(widget.employee.name[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Editar funcionário',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
                Text(
                  '@${widget.employee.username}',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nome
              CustomInput(
                controller: _nameCtrl,
                hintText: 'Nome completo',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Nome'),
              ),
              const SizedBox(height: 12),

              // Username
              CustomInput(
                controller: _userCtrl,
                hintText: 'Usuário',
                prefixIcon: Icons.alternate_email_rounded,
                validator: Validators.username,
              ),
              const SizedBox(height: 12),

              // Role
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(
                  labelText: 'Perfil',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'employee', child: Text('Funcionário')),
                  DropdownMenuItem(
                      value: 'manager', child: Text('Gerente')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'employee'),
              ),

              // Aviso se mudou o username
              if (_userCtrl.text.trim().toLowerCase() !=
                  widget.employee.username)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: Colors.orange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'O funcionário precisará usar o novo '
                            'usuário no próximo login.',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        // Botão deletar — vermelho, à esquerda
        TextButton.icon(
          onPressed: _saving ? null : _confirmDelete,
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          label: const Text('Remover', style: TextStyle(color: Colors.red)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}