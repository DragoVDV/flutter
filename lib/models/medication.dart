enum PillStatus { taken, pending, missed }

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.time,
    required this.status,
    required this.day,
  });

  final String id;
  final String name;
  final String time;
  final PillStatus status;
  final int day; // 0=Пн … 6=Нд

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'] as String,
    name: json['name'] as String,
    time: json['time'] as String,
    status: PillStatus.values.byName(json['status'] as String),
    day: (json['day'] as int?) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'time': time,
    'status': status.name,
    'day': day,
  };

  Medication copyWith({
    String? id,
    String? name,
    String? time,
    PillStatus? status,
    int? day,
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    time: time ?? this.time,
    status: status ?? this.status,
    day: day ?? this.day,
  );
}
