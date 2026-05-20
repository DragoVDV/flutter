import 'package:flutter/material.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/stat_card.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

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

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

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

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.primary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(item.$1, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(item.$2, style: const TextStyle(fontSize: 15))),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
