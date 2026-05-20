import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_1/cubits/meds/meds_cubit.dart';
import 'package:lab_1/models/medication.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/box_grid.dart';
import 'package:lab_1/widgets/connectivity_banner.dart';
import 'package:lab_1/widgets/home_app_bar.dart';
import 'package:lab_1/widgets/med_dialog.dart';
import 'package:lab_1/widgets/med_menu.dart';
import 'package:lab_1/widgets/pill_card.dart';
import 'package:lab_1/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  static const _days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  Future<void> _add(BuildContext context, int selectedDay) async {
    final med = await showDialog<Medication>(
      context: context,
      builder: (_) => MedDialog(day: selectedDay),
    );
    if (med == null || !context.mounted) return;
    context.read<MedicationCubit>().add(med);
  }

  Future<void> _edit(BuildContext context, Medication med) async {
    final updated = await showDialog<Medication>(
      context: context,
      builder: (_) => MedDialog(day: med.day, initial: med),
    );
    if (updated == null || !context.mounted) return;
    context.read<MedicationCubit>().update(updated);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.1 : 20.0;

    return BlocBuilder<MedicationCubit, MedsState>(
      builder: (context, state) {
        final meds = state is MedsLoaded ? state.meds : <Medication>[];
        final selectedDay = state is MedsLoaded
            ? state.selectedDay
            : DateTime.now().weekday - 1;
        final dayMeds = meds.where((m) => m.day == selectedDay).toList();
        final isLoading = state is MedsLoading;

        return ConnectivityBanner(
          child: Scaffold(
            backgroundColor: AppColors.background,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _add(context, selectedDay),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      HomeAppBar(hPad: hPad),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: hPad,
                          vertical: 16,
                        ),
                        sliver: SliverList.list(
                          children: [
                            const SectionHeader(title: 'Медичний бокс'),
                            const SizedBox(height: 12),
                            BoxGrid(
                              meds: meds,
                              days: _days,
                              selectedDay: selectedDay,
                              onDayTap: (d) =>
                                  context.read<MedicationCubit>().selectDay(d),
                            ),
                            const SizedBox(height: 24),
                            SectionHeader(title: _days[selectedDay]),
                            const SizedBox(height: 12),
                            if (dayMeds.isEmpty)
                              const Center(
                                child: Text(
                                  'Натисніть + щоб додати ліки',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            else
                              ...dayMeds.map(
                                (m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: PillCard(
                                    name: m.name,
                                    time: m.time,
                                    status: m.status,
                                    trailing: MedMenu(
                                      onEdit: () => _edit(context, m),
                                      onDelete: () => context
                                          .read<MedicationCubit>()
                                          .delete(m.id),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
