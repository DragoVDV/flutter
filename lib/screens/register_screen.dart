import 'package:flutter/material.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/app_button.dart';
import 'package:lab_1/widgets/app_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context),
              const SizedBox(height: 32),
              const AppTextField(
                hint: "Ваше ім'я",
                label: "Ім'я",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              const AppTextField(
                hint: '••••••••',
                label: 'Підтвердіть пароль',
                icon: Icons.lock_outlined,
                obscure: true,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Зареєструватися',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Column(
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
      ],
    );
  }
}
