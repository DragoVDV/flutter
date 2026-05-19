import 'package:flutter/material.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/pill_card.dart';

class BoxSlot extends StatelessWidget {
  const BoxSlot({
    required this.day,
    required this.status,
    super.key,
  });

  final String day;
  final PillStatus status;

  Color get _bg => switch (status) {
    PillStatus.taken => AppColors.taken,
    PillStatus.pending => AppColors.border,
    PillStatus.missed => AppColors.missed,
  };

  Color get _fg => switch (status) {
    PillStatus.taken => Colors.white,
    PillStatus.pending => AppColors.textSecondary,
    PillStatus.missed => Colors.white,
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: _fg,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
