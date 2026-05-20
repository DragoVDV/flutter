import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_1/cubits/auth/auth_cubit.dart';
import 'package:lab_1/screens/profile_screen.dart';
import 'package:lab_1/screens/sensor_screen.dart';
import 'package:lab_1/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({required this.hPad, super.key});

  final double hPad;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthCubit, String>(
      (c) => c.state is AuthAuthenticated
          ? (c.state as AuthAuthenticated).user.name
          : '',
    );
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      elevation: 0,
      titleSpacing: hPad,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Привіт, $name!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const Text(
            'Перевірте свої ліки',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.sensors, color: AppColors.primary),
          tooltip: 'Датчик медбоксу',
          onPressed: () => Navigator.pushNamed(context, SensorScreen.routeName),
        ),
        Padding(
          padding: EdgeInsets.only(right: hPad),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 18,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
