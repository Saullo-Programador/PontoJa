import 'package:flutter/material.dart';
import 'package:ponto_eletronico/core/utils/validators.dart';
import 'package:ponto_eletronico/shared/widgets/custom_input.dart';

class CreateEmployeeDialog extends StatefulWidget {
  final Future<void> Function(
          String name, String email, String password, String role)
      onSave;

  const CreateEmployeeDialog({super.key, required this.onSave});

  @override
  State<CreateEmployeeDialog> createState() => _CreateEmployeeDialogState();
}

class _CreateEmployeeDialogState extends State<CreateEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'employee';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await widget.onSave(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _role,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo usuário'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInput(
              controller: _nameCtrl,
              hintText: 'Nome completo',
              prefixIcon: Icons.person_outline,
              validator: (v) => Validators.required(v, 'Nome'),
            ),
            const SizedBox(height: 12),
            CustomInput(
              controller: _emailCtrl,
              hintText: 'E-mail',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            CustomInput(
              controller: _passCtrl,
              hintText: 'Senha (mín. 6 caracteres)',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: InputDecoration(
                labelText: 'Perfil',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'employee', child: Text('Funcionário')),
                DropdownMenuItem(value: 'manager', child: Text('Gerente')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'employee'),
            ),
          ],
        ),
      ),
      actions: [
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
              : const Text('Criar'),
        ),
      ],
    );
  }
}