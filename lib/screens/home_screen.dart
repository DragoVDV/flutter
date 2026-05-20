import 'package:flutter/material.dart';
import 'package:lab_1/data/cached_medication_repository.dart';
import 'package:lab_1/data/medication_repository.dart';
import 'package:lab_1/models/medication.dart';
import 'package:lab_1/providers/auth_provider.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/box_grid.dart';
import 'package:lab_1/widgets/connectivity_banner.dart';
import 'package:lab_1/widgets/home_app_bar.dart';
import 'package:lab_1/widgets/med_dialog.dart';
import 'package:lab_1/widgets/med_menu.dart';
import 'package:lab_1/widgets/pill_card.dart';
import 'package:lab_1/widgets/section_header.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  final MedicationRepository _repo = CachedMedicationRepository();
  late Future<List<Medication>> _medsFuture;
  int _selectedDay = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  String get _email => context.read<AuthProvider>().user?.email ?? '';

  void _refresh() => setState(() {
    _medsFuture = _repo.getAll(_email);
  });

  Future<void> _add() async {
    final med = await showDialog<Medication>(
      context: context,
      builder: (_) => MedDialog(day: _selectedDay),
    );
    if (med == null) return;
    await _repo.save(med, _email);
    _refresh();
  }

  Future<void> _edit(Medication med) async {
    final updated = await showDialog<Medication>(
      context: context,
      builder: (_) => MedDialog(day: med.day, initial: med),
    );
    if (updated == null) return;
    await _repo.update(updated, _email);
    _refresh();
  }

  Future<void> _delete(String id) async {
    await _repo.delete(id, _email);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.1 : 20.0;
    return ConnectivityBanner(
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton(
          onPressed: _add,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: FutureBuilder<List<Medication>>(
          future: _medsFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final meds = snap.data ?? [];
            final dayMeds = meds.where((m) => m.day == _selectedDay).toList();
            return CustomScrollView(
              slivers: [
                HomeAppBar(
                  hPad: hPad,
                  onProfileReturn: () {
                    if (mounted) setState(() {});
                  },
                ),
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
                        selectedDay: _selectedDay,
                        onDayTap: (d) => setState(() => _selectedDay = d),
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(title: _days[_selectedDay]),
                      const SizedBox(height: 12),
                      if (dayMeds.isEmpty)
                        const Center(
                          child: Text(
                            'Натисніть + щоб додати ліки',
                            style: TextStyle(color: AppColors.textSecondary),
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
                                onEdit: () => _edit(m),
                                onDelete: () => _delete(m.id),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
