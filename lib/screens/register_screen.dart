import 'package:flutter/material.dart';
import 'package:lab_1/core/validator.dart';
import 'package:lab_1/providers/auth_provider.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/app_button.dart';
import 'package:lab_1/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final _nameCtrl = TextEditingController();
  late final _emailCtrl = TextEditingController();
  late final _passCtrl = TextEditingController();
  late final _confirmCtrl = TextEditingController();
  String? _nameError;
  String? _emailError;
  String? _passError;
  String? _confirmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nameErr = Validator.name(_nameCtrl.text);
    final emailErr = Validator.email(_emailCtrl.text);
    final passErr = Validator.password(_passCtrl.text);
    final confirmErr =
        Validator.confirmPassword(_passCtrl.text, _confirmCtrl.text);
    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passError = passErr;
      _confirmError = confirmErr;
    });
    if ([nameErr, emailErr, passErr, confirmErr].any((e) => e != null)) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) return Navigator.popUntil(context, (r) => r.isFirst);
    final msg = auth.errorMessage ?? 'Помилка реєстрації';
    if (msg.contains('Email')) {
      setState(() => _emailError = msg);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.2 : 24.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Створити акаунт',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Заповніть форму для реєстрації',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              AppTextField(
                hint: "Ваше ім'я",
                label: "Ім'я",
                icon: Icons.person_outline,
                controller: _nameCtrl,
                errorText: _nameError,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              AppTextField(
                hint: '••••••••',
                label: 'Підтвердіть пароль',
                icon: Icons.lock_outlined,
                obscure: true,
                controller: _confirmCtrl,
                errorText: _confirmError,
              ),
              const SizedBox(height: 24),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else
                AppButton(label: 'Зареєструватися', onTap: _submit),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
