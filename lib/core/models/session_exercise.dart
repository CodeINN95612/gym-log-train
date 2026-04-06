import 'exercise.dart';

class SessionExercise {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final int orderIndex;
  final String? notes;
  // Joined from exercises table for display
  final Exercise? exercise;

  const SessionExercise({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.orderIndex,
    this.notes,
    this.exercise,
  });

  factory SessionExercise.fromMap(Map<String, dynamic> map) => SessionExercise(
        id: map['id'] as int?,
        sessionId: map['session_id'] as int,
        exerciseId: map['exercise_id'] as int,
        orderIndex: map['order_index'] as int,
        notes: map['notes'] as String?,
        exercise: map.containsKey('exercise_name')
            ? Exercise(
                id: map['exercise_id'] as int,
                name: map['exercise_name'] as String,
                category: map['exercise_category'] as String?,
                muscleFocus: map['exercise_muscle_focus'] as String?,
                createdAt: map['exercise_created_at'] as int? ?? 0,
              )
            : null,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'session_id': sessionId,
        'exercise_id': exerciseId,
        'order_index': orderIndex,
        'notes': notes,
      };

  SessionExercise copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? orderIndex,
    String? notes,
    Exercise? exercise,
  }) =>
      SessionExercise(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        exerciseId: exerciseId ?? this.exerciseId,
        orderIndex: orderIndex ?? this.orderIndex,
        notes: notes ?? this.notes,
        exercise: exercise ?? this.exercise,
      );
}
