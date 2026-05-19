import 'package:flutter/material.dart';
import 'package:lab_1/screens/home_screen.dart';
import 'package:lab_1/screens/register_screen.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/app_button.dart';
import 'package:lab_1/widgets/app_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.2 : 24.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _header(context),
              const SizedBox(height: 40),
              const AppTextField(
                hint: 'you@example.com',
                label: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              const AppTextField(
                hint: '••••••••',
                label: 'Пароль',
                icon: Icons.lock_outlined,
                obscure: true,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Увійти',
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  HomeScreen.routeName,
                ),
              ),
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
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
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
          onPressed: () => Navigator.pushNamed(
            context,
            RegisterScreen.routeName,
          ),
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
