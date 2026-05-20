sealed class SensorState {
  const SensorState();
}

final class SensorDisconnected extends SensorState {
  const SensorDisconnected();
}

final class SensorConnecting extends SensorState {
  const SensorConnecting();
}

final class SensorConnected extends SensorState {
  const SensorConnected({required this.slots, required this.lastUpdate});

  final List<SlotState> slots;
  final DateTime lastUpdate;

  int get pillsPresent => slots.where((s) => s.hasPill).length;
  int get totalSlots => slots.length;
}

final class SensorError extends SensorState {
  const SensorError(this.message);

  final String message;
}

class SlotState {
  const SlotState({
    required this.id,
    required this.label,
    required this.hasPill,
    required this.lastUpdated,
  });

  final int id;
  final String label;
  final bool hasPill;
  final DateTime lastUpdated;
}
