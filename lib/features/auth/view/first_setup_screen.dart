import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ponto_eletronico/app/router/app_routes.dart';
import 'package:ponto_eletronico/core/constants/firestore_constants.dart';
import 'package:ponto_eletronico/core/utils/validators.dart';
import 'package:ponto_eletronico/shared/widgets/custom_button.dart';
import 'package:ponto_eletronico/shared/widgets/custom_input.dart';

/// Exibida apenas na primeira execução (sem nenhum usuário no Firestore).
/// Cria o gerente master e nunca mais aparece.
class FirstSetupScreen extends StatefulWidget {
  const FirstSetupScreen({super.key});

  @override
  State<FirstSetupScreen> createState() => _FirstSetupScreenState();
}

class _FirstSetupScreenState extends State<FirstSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Cria usuário no Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      // 2. Salva no Firestore com role = manager
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.users)
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': 'manager',
      });

      if (!mounted) return;
      // 3. Vai direto para a tela do gerente
      Navigator.pushReplacementNamed(context, AppRoutes.manager);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'email-already-in-use' => 'Este e-mail já está em uso.',
          'weak-password' => 'Senha muito fraca (mínimo 6 caracteres).',
          'invalid-email' => 'E-mail inválido.',
          _ => 'Erro ao criar conta: ${e.message}',
        };
      });
    } catch (e) {
      setState(() => _error = 'Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone
                    Icon(Icons.admin_panel_settings_outlined,
                        size: 64, color: primary),
                    const SizedBox(height: 16),

                    // Título
                    Text(
                      'Primeiro acesso',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie a conta do gerente master para começar a usar o sistema.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Nome
                    CustomInput(
                      controller: _nameCtrl,
                      hintText: 'Nome completo',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => Validators.required(v, 'Nome'),
                      focusNode: _nameFocus,
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_emailFocus);
                      },
                    ),
                    const SizedBox(height: 14),

                    // E-mail
                    CustomInput(
                      controller: _emailCtrl,
                      hintText: 'E-mail',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      focusNode: _emailFocus,
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Senha
                    CustomInput(
                      controller: _passCtrl,
                      hintText: 'Senha (mín. 6 caracteres)',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: Validators.password,
                      focusNode: _passwordFocus,
                      onSubmitted: (_) {
                        _createAdmin();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botão
                    CustomButton(
                      text: 'Criar conta de gerente',
                      isLoading: _loading,
                      onPressed: _createAdmin,
                      color: Theme.of(context).primaryColor,
                    ),

                    // Erro
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    // Nota de segurança
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Esta tela só aparece uma vez e desaparece após o primeiro cadastro.',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}