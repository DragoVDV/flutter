import 'package:flutter/material.dart';
import 'package:lab_1/screens/home_screen.dart';
import 'package:lab_1/screens/login_screen.dart';
import 'package:lab_1/screens/profile_screen.dart';
import 'package:lab_1/screens/register_screen.dart';
import 'package:lab_1/theme/app_colors.dart';

void main() => runApp(const MedBoxApp());

class MedBoxApp extends StatelessWidget {
  const MedBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
      },
    );
  }
}
