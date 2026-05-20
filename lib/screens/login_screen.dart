import 'package:flutter/material.dart';
import 'package:lab_1/core/validator.dart';
import 'package:lab_1/providers/auth_provider.dart';
import 'package:lab_1/screens/register_screen.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/app_button.dart';
import 'package:lab_1/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _emailCtrl = TextEditingController();
  late final _passCtrl = TextEditingController();
  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailErr = Validator.email(_emailCtrl.text);
    final passErr = Validator.password(_passCtrl.text);
    setState(() {
      _emailError = emailErr;
      _passError = passErr;
    });
    if (emailErr != null || passErr != null) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Помилка входу')),
      );
    }
    // On success AuthProvider.status → authenticated → MedBoxApp rebuilds home:
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.2 : 24.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _header(context),
              const SizedBox(height: 40),
              AppTextField(
                hint: 'you@example.com',
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _emailCtrl,
                errorText: _emailError,
              ),
              const SizedBox(height: 16),
              AppTextField(
                hint: '••••••••',
                label: 'Пароль',
                icon: Icons.lock_outlined,
                obscure: true,
                controller: _passCtrl,
                errorText: _passError,
              ),
              const SizedBox(height: 24),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else
                AppButton(label: 'Увійти', onTap: _submit),
              const SizedBox(height: 12),
              _registerRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.medical_services_rounded,
          size: 48,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'MedBox',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Відстежуйте свої ліки',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _registerRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Немає акаунту? ',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, RegisterScreen.routeName),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.accent,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Зареєструватися',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
