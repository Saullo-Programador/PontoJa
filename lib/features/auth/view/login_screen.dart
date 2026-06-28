import 'package:flutter/material.dart';
import 'package:ponto_eletronico/shared/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:ponto_eletronico/app/router/app_routes.dart';
import 'package:ponto_eletronico/core/utils/validators.dart';
import 'package:ponto_eletronico/features/auth/controller/login_controller.dart';
import 'package:ponto_eletronico/shared/widgets/custom_button.dart';
import 'package:ponto_eletronico/shared/widgets/custom_input.dart';
import 'package:ponto_eletronico/shared/widgets/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<LoginController>();
    await ctrl.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;

    if (ctrl.status == LoginStatus.success) {
      final route = ctrl.role == 'manager'
          ? AppRoutes.manager
          : AppRoutes.employee;
      Navigator.pushReplacementNamed(context, route);
    } else if (ctrl.status == LoginStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ctrl.errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildForm() {
    return Consumer<LoginController>(
      builder: (_, ctrl, __) => Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Entrar',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Acesse o sistema de ponto eletrônico',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 16),
            CustomInput(
              controller: _passCtrl,
              hintText: 'Senha',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              validator: Validators.password,
              focusNode: _passwordFocus,
              onSubmitted: (_) {
                _submit();
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Entrar',
              isLoading: ctrl.status == LoginStatus.loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      mobile: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image(
                    image: isDark
                        ? AssetImage('assets/images/logo_app_dark.png')
                        : AssetImage('assets/images/logo_app.png'),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 32),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
      desktop: Scaffold(
        body: Row(
          children: [
            // Painel esquerdo – banner
            Expanded(
              child: Container(
                decoration: AppTheme.background(context),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: Theme.of(context).brightness == Brightness.dark
                            ? AssetImage('assets/images/logo_web_dark.png')
                            : AssetImage('assets/images/logo_Web.png'),
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Painel direito – formulário
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(-5, 0), // sombra para a esquerda
                  ),
                ],
              ),
              child: SizedBox(
                width: 440,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: _buildForm(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
