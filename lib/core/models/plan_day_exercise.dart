import 'exercise.dart';

class PlanDayExercise {
  final int? id;
  final int planDayId;
  final int exerciseId;
  final int orderIndex;
  final String? notes;
  // Joined from exercises table for display
  final Exercise? exercise;

  const PlanDayExercise({
    this.id,
    required this.planDayId,
    required this.exerciseId,
    required this.orderIndex,
    this.notes,
    this.exercise,
  });

  factory PlanDayExercise.fromMap(Map<String, dynamic> map) => PlanDayExercise(
        id: map['id'] as int?,
        planDayId: map['plan_day_id'] as int,
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
        'plan_day_id': planDayId,
        'exercise_id': exerciseId,
        'order_index': orderIndex,
        'notes': notes,
      };

  PlanDayExercise copyWith({
    int? id,
    int? planDayId,
    int? exerciseId,
    int? orderIndex,
    String? notes,
    Exercise? exercise,
  }) =>
      PlanDayExercise(
        id: id ?? this.id,
        planDayId: planDayId ?? this.planDayId,
        exerciseId: exerciseId ?? this.exerciseId,
        orderIndex: orderIndex ?? this.orderIndex,
        notes: notes ?? this.notes,
        exercise: exercise ?? this.exercise,
      );
}
