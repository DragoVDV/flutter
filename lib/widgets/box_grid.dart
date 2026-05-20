import 'package:flutter/material.dart';
import 'package:lab_1/models/medication.dart';
import 'package:lab_1/widgets/box_slot.dart';

class BoxGrid extends StatelessWidget {
  const BoxGrid({
    required this.meds,
    required this.days,
    required this.selectedDay,
    required this.onDayTap,
    super.key,
  });

  final List<Medication> meds;
  final List<String> days;
  final int selectedDay;
  final ValueChanged<int> onDayTap;

  PillStatus? _statusFor(int day) {
    final dayMeds = meds.where((m) => m.day == day).toList();
    if (dayMeds.isEmpty) return null;
    if (dayMeds.any((m) => m.status == PillStatus.missed)) {
      return PillStatus.missed;
    }
    if (dayMeds.any((m) => m.status == PillStatus.pending)) {
      return PillStatus.pending;
    }
    return PillStatus.taken;
  }

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
      itemBuilder: (_, i) => BoxSlot(
        day: days[i],
        status: _statusFor(i),
        isSelected: i == selectedDay,
        onTap: () => onDayTap(i),
      ),
    );
  }
}
