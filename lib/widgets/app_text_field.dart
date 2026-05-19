import 'package:flutter/material.dart';
import 'package:lab_1/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hint,
    this.label,
    this.obscure = false,
    this.icon,
    super.key,
  });

  final String hint;
  final String? label;
  final bool obscure;
  final IconData? icon;

  static final _radius = BorderRadius.circular(8);

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
