// Named SetEntry because 'Set' is a Dart core type.
class SetEntry {
  final int? id;
  final int sessionExerciseId;
  final int setNumber;
  final int? reps;
  final double? weightKg;
  final int? durationSeconds;
  final bool completed;

  const SetEntry({
    this.id,
    required this.sessionExerciseId,
    required this.setNumber,
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.completed = true,
  });

  factory SetEntry.fromMap(Map<String, dynamic> map) => SetEntry(
        id: map['id'] as int?,
        sessionExerciseId: map['session_exercise_id'] as int,
        setNumber: map['set_number'] as int,
        reps: map['reps'] as int?,
        weightKg: map['weight_kg'] as double?,
        durationSeconds: map['duration_seconds'] as int?,
        completed: (map['completed'] as int? ?? 1) == 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'session_exercise_id': sessionExerciseId,
        'set_number': setNumber,
        'reps': reps,
        'weight_kg': weightKg,
        'duration_seconds': durationSeconds,
        'completed': completed ? 1 : 0,
      };

  SetEntry copyWith({
    int? id,
    int? sessionExerciseId,
    int? setNumber,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    bool? completed,
    bool clearReps = false,
    bool clearWeightKg = false,
    bool clearDurationSeconds = false,
  }) =>
      SetEntry(
        id: id ?? this.id,
        sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
        setNumber: setNumber ?? this.setNumber,
        reps: clearReps ? null : (reps ?? this.reps),
        weightKg: clearWeightKg ? null : (weightKg ?? this.weightKg),
        durationSeconds: clearDurationSeconds
            ? null
            : (durationSeconds ?? this.durationSeconds),
        completed: completed ?? this.completed,
      );
}
