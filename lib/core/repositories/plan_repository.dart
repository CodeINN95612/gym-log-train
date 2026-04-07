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

  /// Returns a map of traineeId → list of {weekday, exercise_count} for every
  /// trainee that has at least one plan day configured.
  Future<Map<int, List<Map<String, int>>>> getPlanSummariesAll() async {
    final rows = await db.rawQuery('''
      SELECT pd.trainee_id, pd.weekday, COUNT(pde.id) AS exercise_count
      FROM plan_days pd
      LEFT JOIN plan_day_exercises pde ON pde.plan_day_id = pd.id
      GROUP BY pd.trainee_id, pd.weekday
      ORDER BY pd.trainee_id, pd.weekday
    ''');
    final result = <int, List<Map<String, int>>>{};
    for (final row in rows) {
      final tid = row['trainee_id'] as int;
      result.putIfAbsent(tid, () => []).add({
        'weekday': row['weekday'] as int,
        'count': row['exercise_count'] as int,
      });
    }
    return result;
  }

  /// Copies all plan days and exercises from [fromTraineeId] to [toTraineeId],
  /// replacing whatever the target trainee currently has.
  Future<void> clonePlan(int fromTraineeId, int toTraineeId) async {
    await db.transaction((txn) async {
      // Delete existing plan for target (cascades to plan_day_exercises)
      await txn.delete(
          'plan_days', where: 'trainee_id = ?', whereArgs: [toTraineeId]);

      // Copy each source day
      final sourceDays = await txn.query('plan_days',
          where: 'trainee_id = ?',
          whereArgs: [fromTraineeId],
          orderBy: 'weekday ASC');

      for (final day in sourceDays) {
        final newDayId = await txn.insert('plan_days', {
          'trainee_id': toTraineeId,
          'weekday': day['weekday'],
          'label': day['label'],
        });

        final exercises = await txn.query('plan_day_exercises',
            where: 'plan_day_id = ?',
            whereArgs: [day['id']],
            orderBy: 'order_index ASC');

        for (final ex in exercises) {
          await txn.insert('plan_day_exercises', {
            'plan_day_id': newDayId,
            'exercise_id': ex['exercise_id'],
            'order_index': ex['order_index'],
          });
        }
      }
    });
  }
}
