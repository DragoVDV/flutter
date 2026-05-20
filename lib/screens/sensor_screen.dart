import 'package:flutter/material.dart';
import 'package:lab_1/providers/sensor_provider.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/sensor_widgets.dart';
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
            StatusChip(connected: sensor.isConnected),
            const SizedBox(height: 8),
            if (sensor.lastUpdate != null)
              Text(
                'Оновлено: ${_fmt(sensor.lastUpdate!)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 20),
            if (sensor.connectionError != null)
              ErrorCard(message: sensor.connectionError!),
            if (sensor.slots.isEmpty && sensor.isConnected)
              const WaitingCard()
            else if (sensor.slots.isNotEmpty) ...[
              SummaryCard(
                present: sensor.pillsPresent,
                total: sensor.totalSlots,
              ),
              const SizedBox(height: 16),
              Expanded(child: SlotGrid(slots: sensor.slots)),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}
