import 'package:flutter/material.dart';
import 'package:lab_1/data/local/local_medication_repository.dart';
import 'package:lab_1/data/medication_repository.dart';
import 'package:lab_1/models/medication.dart';
import 'package:lab_1/providers/auth_provider.dart';
import 'package:lab_1/screens/profile_screen.dart';
import 'package:lab_1/screens/sensor_screen.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/box_slot.dart';
import 'package:lab_1/widgets/connectivity_banner.dart';
import 'package:lab_1/widgets/med_dialog.dart';
import 'package:lab_1/widgets/pill_card.dart';
import 'package:lab_1/widgets/section_header.dart';
import 'package:provider/provider.dart';

enum _MedAction { edit, delete }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  final MedicationRepository _medRepo = LocalMedicationRepository();
  List<Medication> _meds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMeds();
  }

  String get _userEmail =>
      context.read<AuthProvider>().user?.email ?? '';

  Future<void> _loadMeds() async {
    final meds = await _medRepo.getAll(_userEmail);
    if (!mounted) return;
    setState(() {
      _meds = meds;
      _loading = false;
    });
  }

  List<PillStatus> get _boxSlots => List.generate(
    7,
    (i) => i < _meds.length ? _meds[i].status : PillStatus.pending,
  );

  Future<void> _showAddDialog() async {
    final med = await showDialog<Medication>(
      context: context,
      builder: (_) => const MedDialog(),
    );
    if (med == null) return;
    await _medRepo.save(med, _userEmail);
    await _loadMeds();
  }

  Future<void> _showEditDialog(Medication med) async {
    final updated = await showDialog<Medication>(
      context: context,
      builder: (_) => MedDialog(initial: med),
    );
    if (updated == null) return;
    await _medRepo.update(updated, _userEmail);
    await _loadMeds();
  }

  Future<void> _deleteMed(String id) async {
    await _medRepo.delete(id, _userEmail);
    await _loadMeds();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.1 : 20.0;
    return ConnectivityBanner(
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _appBar(context, hPad),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: 16,
                    ),
                    sliver: SliverList.list(
                      children: [
                        const SectionHeader(title: 'Медичний бокс'),
                        const SizedBox(height: 12),
                        _BoxGrid(days: _days, slots: _boxSlots),
                        const SizedBox(height: 24),
                        const SectionHeader(title: 'Сьогодні'),
                        const SizedBox(height: 12),
                        if (_meds.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Center(
                              child: Text(
                                'Натисніть + щоб додати ліки',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._meds.map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: PillCard(
                                name: m.name,
                                time: m.time,
                                status: m.status,
                                trailing: _MedMenu(
                                  onEdit: () => _showEditDialog(m),
                                  onDelete: () => _deleteMed(m.id),
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
  }

  SliverAppBar _appBar(BuildContext context, double hPad) {
    final name = context.watch<AuthProvider>().user?.name ?? '';
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
          onPressed: () =>
              Navigator.pushNamed(context, SensorScreen.routeName),
        ),
        Padding(
          padding: EdgeInsets.only(right: hPad),
          child: GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, ProfileScreen.routeName);
              if (mounted) setState(() {});
            },
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

class _MedMenu extends StatelessWidget {
  const _MedMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MedAction>(
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
        size: 20,
      ),
      itemBuilder: (_) => const [
        PopupMenuItem(value: _MedAction.edit, child: Text('Редагувати')),
        PopupMenuItem(value: _MedAction.delete, child: Text('Видалити')),
      ],
      onSelected: (action) => switch (action) {
        _MedAction.edit => onEdit(),
        _MedAction.delete => onDelete(),
      },
    );
  }
}

class _BoxGrid extends StatelessWidget {
  const _BoxGrid({required this.days, required this.slots});

  final List<String> days;
  final List<PillStatus> slots;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.8,
      ),
      itemCount: days.length,
      itemBuilder: (_, i) => BoxSlot(day: days[i], status: slots[i]),
    );
  }
}
