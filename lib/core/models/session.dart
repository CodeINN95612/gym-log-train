class Session {
  final int? id;
  final int traineeId;
  final int? planDayId;
  final String date; // YYYY-MM-DD
  final String? notes;
  final int? startedAt; // unix ms
  final int? endedAt; // unix ms, null = in progress

  const Session({
    this.id,
    required this.traineeId,
    this.planDayId,
    required this.date,
    this.notes,
    this.startedAt,
    this.endedAt,
  });

  bool get isInProgress => endedAt == null;

  DateTime? get startedAtDate => startedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(startedAt!)
      : null;

  DateTime? get endedAtDate => endedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(endedAt!)
      : null;

  factory Session.fromMap(Map<String, dynamic> map) => Session(
        id: map['id'] as int?,
        traineeId: map['trainee_id'] as int,
        planDayId: map['plan_day_id'] as int?,
        date: map['date'] as String,
        notes: map['notes'] as String?,
        startedAt: map['started_at'] as int?,
        endedAt: map['ended_at'] as int?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'trainee_id': traineeId,
        'plan_day_id': planDayId,
        'date': date,
        'notes': notes,
        'started_at': startedAt,
        'ended_at': endedAt,
      };

  Session copyWith({
    int? id,
    int? traineeId,
    int? planDayId,
    String? date,
    String? notes,
    int? startedAt,
    int? endedAt,
    bool clearEndedAt = false,
    bool clearPlanDayId = false,
  }) =>
      Session(
        id: id ?? this.id,
        traineeId: traineeId ?? this.traineeId,
        planDayId: clearPlanDayId ? null : (planDayId ?? this.planDayId),
        date: date ?? this.date,
        notes: notes ?? this.notes,
        startedAt: startedAt ?? this.startedAt,
        endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      );
}
