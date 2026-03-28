import { SQLiteDatabase } from 'expo-sqlite';
import { PlanDay, PlanDayExercise } from '../types';

export async function getPlanDays(db: SQLiteDatabase, traineeId: number): Promise<PlanDay[]> {
  return db.getAllAsync<PlanDay>(
    'SELECT * FROM plan_days WHERE trainee_id = ? ORDER BY weekday ASC',
    [traineeId]
  );
}

export async function getPlanDayExercises(db: SQLiteDatabase, planDayId: number): Promise<PlanDayExercise[]> {
  return db.getAllAsync<PlanDayExercise>(
    `SELECT pde.*, e.name as exercise_name, e.category as exercise_category
     FROM plan_day_exercises pde
     JOIN exercises e ON pde.exercise_id = e.id
     WHERE pde.plan_day_id = ?
     ORDER BY pde.order_index ASC`,
    [planDayId]
  );
}

export async function upsertPlanDay(db: SQLiteDatabase, traineeId: number, weekday: number, label: string | null): Promise<number> {
  const existing = await db.getFirstAsync<PlanDay>(
    'SELECT * FROM plan_days WHERE trainee_id = ? AND weekday = ?',
    [traineeId, weekday]
  );
  if (existing) {
    await db.runAsync('UPDATE plan_days SET label = ? WHERE id = ?', [label, existing.id]);
    return existing.id;
  }
  const result = await db.runAsync(
    'INSERT INTO plan_days (trainee_id, weekday, label) VALUES (?, ?, ?)',
    [traineeId, weekday, label]
  );
  return result.lastInsertRowId;
}

export async function deletePlanDay(db: SQLiteDatabase, planDayId: number): Promise<void> {
  await db.runAsync('DELETE FROM plan_days WHERE id = ?', [planDayId]);
}

export async function addExerciseToPlanDay(db: SQLiteDatabase, planDayId: number, exerciseId: number): Promise<void> {
  const count = await db.getFirstAsync<{ cnt: number }>(
    'SELECT COUNT(*) as cnt FROM plan_day_exercises WHERE plan_day_id = ?',
    [planDayId]
  );
  await db.runAsync(
    'INSERT INTO plan_day_exercises (plan_day_id, exercise_id, order_index) VALUES (?, ?, ?)',
    [planDayId, exerciseId, (count?.cnt ?? 0)]
  );
}

export async function removeExerciseFromPlanDay(db: SQLiteDatabase, planDayExerciseId: number): Promise<void> {
  await db.runAsync('DELETE FROM plan_day_exercises WHERE id = ?', [planDayExerciseId]);
}
