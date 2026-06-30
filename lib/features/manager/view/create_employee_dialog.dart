import 'package:flutter/material.dart';
import 'package:ponto_eletronico/core/utils/validators.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';
import 'package:ponto_eletronico/shared/widgets/custom_input.dart';

class CreateEmployeeDialog extends StatefulWidget {
  final Future<void> Function(
      String name, String username, String password, String role) onSave;

  const CreateEmployeeDialog({super.key, required this.onSave});

  @override
  State<CreateEmployeeDialog> createState() => _CreateEmployeeDialogState();
}

class _CreateEmployeeDialogState extends State<CreateEmployeeDialog> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role    = 'employee';
  bool _saving    = false;
  String _previewEmail = '';

  @override
  void initState() {
    super.initState();
    _userCtrl.addListener(_updatePreview);
  }

  void _updatePreview() {
    final u = _userCtrl.text.trim().toLowerCase();
    setState(() {
      _previewEmail = u.isEmpty ? '' : UserEntity.usernameToEmail(u);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _nameCtrl.text.trim(),
        _userCtrl.text.trim().toLowerCase(),
        _passCtrl.text,
        _role,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Novo usuário'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nome completo
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
                hintText: 'Usuário (ex: joao.silva)',
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.text,
                validator: Validators.username,
              ),

              // Preview do login
              if (_previewEmail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Login: $_previewEmail',
                          style: TextStyle(
                              fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Senha
              CustomInput(
                controller: _passCtrl,
                hintText: 'Senha (mín. 6 caracteres)',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 12),

              // Perfil
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(
                  labelText: 'Perfil',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'employee', child: Text('Funcionário')),
                  DropdownMenuItem(value: 'manager',  child: Text('Gerente')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'employee'),
              ),
            ],
          ),
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Criar'),
        ),
      ],
    );
  }
}