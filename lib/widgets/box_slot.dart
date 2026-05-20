import 'package:flutter/material.dart';
import 'package:lab_1/models/medication.dart';
import 'package:lab_1/theme/app_colors.dart';

class BoxSlot extends StatelessWidget {
  const BoxSlot({
    required this.day,
    required this.status,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String day;
  final PillStatus? status;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _bg => switch (status) {
    PillStatus.taken => AppColors.taken,
    PillStatus.pending => AppColors.border,
    PillStatus.missed => AppColors.missed,
    null => AppColors.background,
  };

  Color get _fg => switch (status) {
    PillStatus.taken => Colors.white,
    PillStatus.pending => AppColors.textSecondary,
    PillStatus.missed => Colors.white,
    null => AppColors.border,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: isSelected ? AppColors.primary : _fg,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
