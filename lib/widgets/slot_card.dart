import 'package:flutter/material.dart';
import 'package:lab_1/providers/sensor_provider.dart';
import 'package:lab_1/theme/app_colors.dart';

class SlotCard extends StatelessWidget {
  const SlotCard({required this.slot, super.key});

  final SlotState slot;

  @override
  Widget build(BuildContext context) {
    final hasPill = slot.hasPill;
    final bg = hasPill ? AppColors.taken.withAlpha(26) : AppColors.border;
    final iconColor = hasPill ? AppColors.taken : AppColors.textSecondary;
    final icon =
        hasPill ? Icons.medication_rounded : Icons.check_circle_outline;
    final label = hasPill ? slot.label : 'Прийнято';

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPill ? AppColors.taken : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 6),
          Text(
            slot.label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color:
                  hasPill ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: iconColor)),
        ],
      ),
    );
  }
}
