import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_1/core/validator.dart';
import 'package:lab_1/cubits/auth/auth_cubit.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/app_button.dart';
import 'package:lab_1/widgets/app_text_field.dart';
import 'package:lab_1/widgets/flashlight_avatar.dart';
import 'package:lab_1/widgets/profile_widgets.dart';
import 'package:lab_1/widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final _nameCtrl = TextEditingController(
    text:
        (context.read<AuthCubit>().state as AuthAuthenticated?)?.user.name ??
        '',
  );
  bool _editing = false;
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final err = Validator.name(_nameCtrl.text);
    setState(() => _nameError = err);
    if (err != null) return;
    context.read<AuthCubit>().updateName(_nameCtrl.text.trim());
    setState(() => _editing = false);
  }

  void _cancelEditing() {
    final state = context.read<AuthCubit>().state;
    _nameCtrl.text = state is AuthAuthenticated ? state.user.name : '';
    setState(() {
      _editing = false;
      _nameError = null;
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Підтвердження виходу'),
        content: const Text('Ви впевнені, що хочете вийти з акаунту?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.missed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    await context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.15 : 20.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'Профіль',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
            color: AppColors.primary,
            onPressed: _editing
                ? _cancelEditing
                : () => setState(() => _editing = true),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              children: [
                const SizedBox(height: 24),
                FlashlightAvatar(name: user?.name ?? ''),
                const SizedBox(height: 16),
                if (_editing)
                  AppTextField(
                    hint: "Ваше ім'я",
                    label: "Ім'я",
                    icon: Icons.person_outline,
                    controller: _nameCtrl,
                    errorText: _nameError,
                  )
                else
                  Text(
                    user?.name ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (_editing) ...[
                  const SizedBox(height: 16),
                  AppButton(label: 'Зберегти', onTap: _save),
                ],
                const SizedBox(height: 32),
                const ProfileStatsRow(),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SectionHeader(title: 'Налаштування'),
                ),
                const SizedBox(height: 12),
                const SettingsList(),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Вийти',
                  outlined: true,
                  onTap: _confirmLogout,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
