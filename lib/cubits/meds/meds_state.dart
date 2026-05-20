import 'package:lab_1/models/medication.dart';

sealed class MedsState {
  const MedsState();
}

final class MedsInitial extends MedsState {
  const MedsInitial();
}

final class MedsLoading extends MedsState {
  const MedsLoading();
}

final class MedsLoaded extends MedsState {
  const MedsLoaded({required this.meds, required this.selectedDay});

  final List<Medication> meds;
  final int selectedDay;

  MedsLoaded copyWith({List<Medication>? meds, int? selectedDay}) => MedsLoaded(
    meds: meds ?? this.meds,
    selectedDay: selectedDay ?? this.selectedDay,
  );
}

final class MedsError extends MedsState {
  const MedsError(this.message);

  final String message;
}
