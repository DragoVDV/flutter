import 'package:flutter/material.dart';
import 'package:lab_1/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool outlined;

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );
  static const _size = Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          minimumSize: _size,
          shape: _shape,
        ),
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        minimumSize: _size,
        shape: _shape,
      ),
      child: Text(label),
    );
  }
}
