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
  final _formKey       = GlobalKey<FormState>();
  final _userCtrl      = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _userFocus     = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _userFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<LoginController>();
    await ctrl.login(_userCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;

    if (ctrl.status == LoginStatus.success) {
      final route = ctrl.role == 'manager' ? AppRoutes.manager : AppRoutes.employee;
      Navigator.pushReplacementNamed(context, route);
    } else if (ctrl.status == LoginStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ctrl.errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildForm({bool isWeb = false}) {

    return Consumer<LoginController>(
      builder: (_, ctrl, __) => Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isWeb ? 'Acesso Gerencial' : 'Olá! 👋',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              isWeb
                  ? 'Entre com seu e-mail e senha'
                  : 'Entre com seu usuário e senha',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Campo usuário (mobile) ou e-mail (web)
            CustomInput(
              controller: _userCtrl,
              hintText: isWeb ? 'E-mail' : 'Usuário',
              prefixIcon: isWeb
                  ? Icons.email_outlined
                  : Icons.alternate_email_rounded,
              keyboardType: isWeb
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              focusNode: _userFocus,
              validator: isWeb ? Validators.email : Validators.usernameOrEmail,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
            ),
            const SizedBox(height: 16),

            CustomInput(
              controller: _passCtrl,
              hintText: 'Senha',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              focusNode: _passwordFocus,
              validator: Validators.password,
              onSubmitted: (_) => _submit(),
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
      // ── Mobile: logo + form com campo "Usuário" ───────────────────────
      mobile: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image(
                    image: isDark
                        ? const AssetImage('assets/images/logo_app_dark.png')
                        : const AssetImage('assets/images/logo_app.png'),
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  _buildForm(isWeb: false),
                ],
              ),
            ),
          ),
        ),
      ),
      // ── Desktop/Web: banner + form com campo "E-mail" ─────────────────
      desktop: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Container(
                decoration: AppTheme.background(context),
                child: Center(
                  child: Image(
                    image: isDark
                        ? const AssetImage('assets/images/logo_web_dark.png')
                        : const AssetImage('assets/images/logo_Web.png'),
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
              child: SizedBox(
                width: 440,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: _buildForm(isWeb: true),
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