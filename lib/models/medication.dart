enum PillStatus { taken, pending, missed }

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.time,
    required this.status,
  });

  final String id;
  final String name;
  final String time;
  final PillStatus status;

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'] as String,
    name: json['name'] as String,
    time: json['time'] as String,
    status: PillStatus.values.byName(json['status'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'time': time,
    'status': status.name,
  };

  Medication copyWith({
    String? id,
    String? name,
    String? time,
    PillStatus? status,
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    time: time ?? this.time,
    status: status ?? this.status,
  );
}
