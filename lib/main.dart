import 'package:flutter/material.dart';
import 'package:lab_1/providers/auth_provider.dart';
import 'package:lab_1/providers/connectivity_provider.dart';
import 'package:lab_1/providers/sensor_provider.dart';
import 'package:lab_1/screens/home_screen.dart';
import 'package:lab_1/screens/login_screen.dart';
import 'package:lab_1/screens/profile_screen.dart';
import 'package:lab_1/screens/register_screen.dart';
import 'package:lab_1/screens/sensor_screen.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final connectivityProvider = ConnectivityProvider();

  await connectivityProvider.init();
  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: connectivityProvider),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
      ],
      child: const MedBoxApp(),
    ),
  );
}

class MedBoxApp extends StatelessWidget {
  const MedBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().status;

    return MaterialApp(
      title: 'MedBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: switch (authStatus) {
        AuthStatus.unknown => const _SplashScreen(),
        AuthStatus.authenticated => const HomeScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
      },
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        SensorScreen.routeName: (_) => const SensorScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
