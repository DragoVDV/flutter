import 'package:flutter/material.dart';
import 'package:lab_1/theme/app_colors.dart';

enum MedAction { edit, delete }

class MedMenu extends StatelessWidget {
  const MedMenu({required this.onEdit, required this.onDelete, super.key});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MedAction>(
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
        size: 20,
      ),
      itemBuilder: (_) => const [
        PopupMenuItem(value: MedAction.edit, child: Text('Редагувати')),
        PopupMenuItem(value: MedAction.delete, child: Text('Видалити')),
      ],
      onSelected: (action) => switch (action) {
        MedAction.edit => onEdit(),
        MedAction.delete => onDelete(),
      },
    );
  }
}
