import 'package:flutter/material.dart';
import 'package:lab_1/providers/sensor_provider.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:provider/provider.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  static const routeName = '/sensor';

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SensorProvider>().connect();
  }

  @override
  Widget build(BuildContext context) {
    final sensor = context.watch<SensorProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'Медбокс — стан пігулок',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusChip(connected: sensor.isConnected),
            const SizedBox(height: 8),
            if (sensor.lastUpdate != null)
              Text(
                'Оновлено: ${_formatTime(sensor.lastUpdate!)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 20),
            if (sensor.connectionError != null)
              _ErrorCard(message: sensor.connectionError!),
            if (sensor.slots.isEmpty && sensor.isConnected)
              const _WaitingCard()
            else if (sensor.slots.isNotEmpty) ...[
              _SummaryCard(
                present: sensor.pillsPresent,
                total: sensor.totalSlots,
              ),
              const SizedBox(height: 16),
              Expanded(child: _SlotGrid(slots: sensor.slots)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.connected});

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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.present, required this.total});

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

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.slots});

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
      itemBuilder: (_, i) => _SlotCard(slot: slots[i]),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});

  final SlotState slot;

  @override
  Widget build(BuildContext context) {
    final hasPill = slot.hasPill;
    final bg = hasPill ? AppColors.taken.withAlpha(26) : AppColors.border;
    final iconColor =
        hasPill ? AppColors.taken : AppColors.textSecondary;
    final icon =
        hasPill ? Icons.medication_rounded : Icons.check_circle_outline;
    final label = hasPill ? slot.label : 'Прийнято';

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPill ? AppColors.taken : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 6),
          Text(
            slot.label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: hasPill ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingCard extends StatelessWidget {
  const _WaitingCard();

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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

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
