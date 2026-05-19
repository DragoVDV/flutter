import 'package:flutter/material.dart';
import 'package:lab_1/theme/app_colors.dart';

enum PillStatus { taken, pending, missed }

class PillCard extends StatelessWidget {
  const PillCard({
    required this.name,
    required this.time,
    required this.status,
    super.key,
  });

  final String name;
  final String time;
  final PillStatus status;

  Color get _color => switch (status) {
    PillStatus.taken => AppColors.taken,
    PillStatus.pending => AppColors.pending,
    PillStatus.missed => AppColors.missed,
  };

  IconData get _icon => switch (status) {
    PillStatus.taken => Icons.check_circle_rounded,
    PillStatus.pending => Icons.schedule_rounded,
    PillStatus.missed => Icons.cancel_rounded,
  };

  String get _label => switch (status) {
    PillStatus.taken => 'Прийнято',
    PillStatus.pending => 'Очікується',
    PillStatus.missed => 'Пропущено',
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _PillIcon(color: _color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _StatusBadge(
              icon: _icon,
              label: _label,
              color: _color,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(Icons.medication_rounded, color: color, size: 22),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
