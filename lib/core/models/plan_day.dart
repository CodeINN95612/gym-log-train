class PlanDay {
  final int? id;
  final int traineeId;
  final int weekday; // 0=Monday, 6=Sunday
  final String? label;

  const PlanDay({
    this.id,
    required this.traineeId,
    required this.weekday,
    this.label,
  });

  factory PlanDay.fromMap(Map<String, dynamic> map) => PlanDay(
        id: map['id'] as int?,
        traineeId: map['trainee_id'] as int,
        weekday: map['weekday'] as int,
        label: map['label'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'trainee_id': traineeId,
        'weekday': weekday,
        'label': label,
      };

  PlanDay copyWith({
    int? id,
    int? traineeId,
    int? weekday,
    String? label,
  }) =>
      PlanDay(
        id: id ?? this.id,
        traineeId: traineeId ?? this.traineeId,
        weekday: weekday ?? this.weekday,
        label: label ?? this.label,
      );
}
