import 'package:flutter/material.dart';
import 'package:lab_1/cubits/sensor/sensor_cubit.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/slot_card.dart';

export 'package:lab_1/widgets/slot_card.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.connected, super.key});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: connected ? AppColors.taken : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          connected ? 'MQTT підключено' : 'Підключення...',
          style: TextStyle(
            fontSize: 13,
            color: connected ? AppColors.taken : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({required this.present, required this.total, super.key});

  final int present;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$present з $total пігулок ще в коробці',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class SlotGrid extends StatelessWidget {
  const SlotGrid({required this.slots, super.key});

  final List<SlotState> slots;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) => SlotCard(slot: slots[i]),
    );
  }
}

class WaitingCard extends StatelessWidget {
  const WaitingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Очікування даних з датчика...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.missed.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.missed),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.missed)),
    );
  }
}
