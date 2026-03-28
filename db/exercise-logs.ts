import { SQLiteDatabase } from 'expo-sqlite';
import { SessionExercise, ExerciseSet } from '../types';

export async function getSessionExercises(db: SQLiteDatabase, sessionId: number): Promise<SessionExercise[]> {
  return db.getAllAsync<SessionExercise>(
    `SELECT se.*, e.name as exercise_name, e.category as exercise_category
     FROM session_exercises se
     JOIN exercises e ON se.exercise_id = e.id
     WHERE se.session_id = ?
     ORDER BY se.order_index ASC`,
    [sessionId]
  );
}

export async function getSets(db: SQLiteDatabase, sessionExerciseId: number): Promise<ExerciseSet[]> {
  return db.getAllAsync<ExerciseSet>(
    'SELECT * FROM sets WHERE session_exercise_id = ? ORDER BY set_number ASC',
    [sessionExerciseId]
  );
}

export async function addExerciseToSession(db: SQLiteDatabase, sessionId: number, exerciseId: number): Promise<number> {
  const count = await db.getFirstAsync<{ cnt: number }>(
    'SELECT COUNT(*) as cnt FROM session_exercises WHERE session_id = ?',
    [sessionId]
  );
  const result = await db.runAsync(
    'INSERT INTO session_exercises (session_id, exercise_id, order_index) VALUES (?, ?, ?)',
    [sessionId, exerciseId, (count?.cnt ?? 0)]
  );
  return result.lastInsertRowId;
}

export async function addSet(
  db: SQLiteDatabase,
  sessionExerciseId: number,
  setNumber: number,
  reps: number | null,
  weight_kg: number | null,
  duration_seconds: number | null
): Promise<number> {
  const result = await db.runAsync(
    'INSERT INTO sets (session_exercise_id, set_number, reps, weight_kg, duration_seconds) VALUES (?, ?, ?, ?, ?)',
    [sessionExerciseId, setNumber, reps, weight_kg, duration_seconds]
  );
  return result.lastInsertRowId;
}

export async function updateSet(
  db: SQLiteDatabase,
  setId: number,
  reps: number | null,
  weight_kg: number | null,
  duration_seconds: number | null
): Promise<void> {
  await db.runAsync(
    'UPDATE sets SET reps = ?, weight_kg = ?, duration_seconds = ? WHERE id = ?',
    [reps, weight_kg, duration_seconds, setId]
  );
}

export async function deleteSet(db: SQLiteDatabase, setId: number): Promise<void> {
  await db.runAsync('DELETE FROM sets WHERE id = ?', [setId]);
}

export async function removeExerciseFromSession(db: SQLiteDatabase, sessionExerciseId: number): Promise<void> {
  await db.runAsync('DELETE FROM session_exercises WHERE id = ?', [sessionExerciseId]);
}

export async function copyPlanDayToSession(db: SQLiteDatabase, planDayId: number, sessionId: number): Promise<void> {
  await db.withTransactionAsync(async () => {
    const planExercises = await db.getAllAsync<{ exercise_id: number; order_index: number }>(
      'SELECT exercise_id, order_index FROM plan_day_exercises WHERE plan_day_id = ? ORDER BY order_index ASC',
      [planDayId]
    );
    for (const pe of planExercises) {
      await db.runAsync(
        'INSERT INTO session_exercises (session_id, exercise_id, order_index) VALUES (?, ?, ?)',
        [sessionId, pe.exercise_id, pe.order_index]
      );
    }
  });
}
