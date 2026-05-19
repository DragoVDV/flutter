import 'package:flutter/material.dart';
import 'package:lab_1/screens/profile_screen.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/box_slot.dart';
import 'package:lab_1/widgets/pill_card.dart';
import 'package:lab_1/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  static const _pills = [
    (name: 'Аспірин', time: '08:00', status: PillStatus.taken),
    (name: 'Вітамін D', time: '12:00', status: PillStatus.pending),
    (name: 'Омега-3', time: '18:00', status: PillStatus.pending),
    (name: 'Магній', time: '21:00', status: PillStatus.missed),
  ];

  static const _days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  static const _slots = [
    PillStatus.taken,
    PillStatus.taken,
    PillStatus.taken,
    PillStatus.pending,
    PillStatus.pending,
    PillStatus.pending,
    PillStatus.pending,
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width > 600 ? width * 0.1 : 20.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
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
                const _BoxGrid(days: _days, slots: _slots),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Сьогодні'),
                const SizedBox(height: 12),
                ..._pills.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PillCard(
                      name: p.name,
                      time: p.time,
                      status: p.status,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _appBar(BuildContext context, double hPad) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      elevation: 0,
      titleSpacing: hPad,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Доброго ранку!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const Text(
            'Понеділок, 19 травня',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: hPad),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              ProfileScreen.routeName,
            ),
            child: const CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 18,
              child: Text(
                'В',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
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
