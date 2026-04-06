import 'package:sqflite/sqflite.dart';
import '../models/plan_day.dart';
import '../models/plan_day_exercise.dart';

class PlanRepository {
  final Database db;

  PlanRepository(this.db);

  Future<List<PlanDay>> getPlanDaysForTrainee(int traineeId) async {
    final rows = await db.query(
      'plan_days',
      where: 'trainee_id = ?',
      whereArgs: [traineeId],
      orderBy: 'weekday ASC',
    );
    return rows.map(PlanDay.fromMap).toList();
  }

  Future<PlanDay?> getPlanDayByWeekday(int traineeId, int weekday) async {
    final rows = await db.query(
      'plan_days',
      where: 'trainee_id = ? AND weekday = ?',
      whereArgs: [traineeId, weekday],
    );
    return rows.isEmpty ? null : PlanDay.fromMap(rows.first);
  }

  Future<List<PlanDayExercise>> getPlanDayExercises(int planDayId) async {
    final rows = await db.rawQuery(
      '''
      SELECT pde.*, e.name AS exercise_name, e.category AS exercise_category,
             e.muscle_focus AS exercise_muscle_focus, e.created_at AS exercise_created_at
      FROM plan_day_exercises pde
      JOIN exercises e ON e.id = pde.exercise_id
      WHERE pde.plan_day_id = ?
      ORDER BY pde.order_index ASC
      ''',
      [planDayId],
    );
    return rows.map(PlanDayExercise.fromMap).toList();
  }

  Future<int> insertPlanDay(PlanDay planDay) async {
    return db.insert('plan_days', planDay.toMap());
  }

  Future<void> updatePlanDay(PlanDay planDay) async {
    await db.update(
      'plan_days',
      planDay.toMap(),
      where: 'id = ?',
      whereArgs: [planDay.id],
    );
  }

  Future<void> deletePlanDay(int id) async {
    await db.delete('plan_days', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertPlanDayExercise(PlanDayExercise pde) async {
    return db.insert('plan_day_exercises', pde.toMap());
  }

  Future<void> deletePlanDayExercise(int id) async {
    await db.delete('plan_day_exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countPlanDayExercises(int planDayId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM plan_day_exercises WHERE plan_day_id = ?',
      [planDayId],
    );
    return result.first['cnt'] as int;
  }
}
