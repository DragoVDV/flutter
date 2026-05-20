import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_1/cubits/sensor/sensor_cubit.dart';
import 'package:lab_1/theme/app_colors.dart';
import 'package:lab_1/widgets/sensor_widgets.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  static const routeName = '/sensor';

  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SensorCubit()..connect(),
      child: Scaffold(
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
        body: BlocBuilder<SensorCubit, SensorState>(
          builder: (context, state) {
            final connected = state is SensorConnected;
            final slots = state is SensorConnected
                ? state.slots
                : <SlotState>[];
            final lastUpdate = state is SensorConnected
                ? state.lastUpdate
                : null;
            final error = state is SensorError ? state.message : null;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(connected: connected),
                  const SizedBox(height: 8),
                  if (lastUpdate != null)
                    Text(
                      'Оновлено: ${_fmt(lastUpdate)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (error != null) ErrorCard(message: error),
                  if (slots.isEmpty && connected)
                    const WaitingCard()
                  else if (slots.isNotEmpty) ...[
                    SummaryCard(
                      present: (state as SensorConnected).pillsPresent,
                      total: state.totalSlots,
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: SlotGrid(slots: slots)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
