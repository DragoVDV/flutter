import 'package:flutter/material.dart';
import 'package:lab_1/screens/login_screen.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/app_button.dart';
import 'package:lab_1/widgets/section_header.dart';
import 'package:lab_1/widgets/stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.15 : 20.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'Профіль',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: const Column(
          children: [
            SizedBox(height: 24),
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary,
              child: Text(
                'ВД',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            _UserInfo(),
            SizedBox(height: 32),
            _StatsRow(),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'Налаштування'),
            ),
            SizedBox(height: 12),
            _SettingsList(),
            SizedBox(height: 24),
            _LogoutButton(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Владислав Дацків',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'volodadatskiv@gmail.com',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: StatCard(
            value: '7',
            label: 'Днів поспіль',
            icon: Icons.local_fire_department,
            color: AppColors.pending,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: '86%',
            label: 'Дотримання',
            icon: Icons.pie_chart_rounded,
            color: AppColors.taken,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: '42',
            label: 'Всього',
            icon: Icons.medication_rounded,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  static const _items = [
    (Icons.notifications_outlined, 'Нагадування'),
    (Icons.palette_outlined, 'Вигляд'),
    (Icons.shield_outlined, 'Конфіденційність'),
    (Icons.help_outline, 'Допомога'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _items.map(_SettingItem.new).toList(),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem(this.item);

  final (IconData, String) item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(item.$1, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.$2,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Вийти',
      outlined: true,
      onTap: () => Navigator.pushReplacementNamed(
        context,
        LoginScreen.routeName,
      ),
    );
  }
}
