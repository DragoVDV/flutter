import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_1/cubits/auth/auth_cubit.dart';
import 'package:lab_1/cubits/connectivity/connectivity_cubit.dart';
import 'package:lab_1/cubits/meds/meds_cubit.dart';
import 'package:lab_1/cubits/sensor/sensor_cubit.dart';
import 'package:lab_1/data/cached_medication_repository.dart';
import 'package:lab_1/screens/home_screen.dart';
import 'package:lab_1/screens/login_screen.dart';
import 'package:lab_1/screens/profile_screen.dart';
import 'package:lab_1/screens/register_screen.dart';
import 'package:lab_1/screens/sensor_screen.dart';
import 'package:lab_1/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final connectivityCubit = ConnectivityCubit();
  await connectivityCubit.init();

  final authCubit = AuthCubit();
  await authCubit.tryAutoLogin();

  final repo = CachedMedicationRepository();
  final medsCubit = MedicationCubit(repo);

  final authState = authCubit.state;
  if (authState is AuthAuthenticated) {
    await medsCubit.load(authState.user.email);
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider.value(value: connectivityCubit),
        BlocProvider.value(value: medsCubit),
        BlocProvider(create: (_) => SensorCubit()),
      ],
      child: const MedBoxApp(),
    ),
  );
}

class MedBoxApp extends StatelessWidget {
  const MedBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) {
          ctx.read<MedicationCubit>().load(state.user.email);
        } else if (state is AuthUnauthenticated) {
          ctx.read<MedicationCubit>().clear();
        }
      },
      child: MaterialApp(
        title: 'MedBox',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (_, state) => switch (state) {
            AuthInitial() => const _SplashScreen(),
            AuthLoading() => const _SplashScreen(),
            AuthAuthenticated() => const HomeScreen(),
            AuthUnauthenticated() => const LoginScreen(),
            AuthError() => const LoginScreen(),
          },
        ),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          SensorScreen.routeName: (_) => const SensorScreen(),
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
