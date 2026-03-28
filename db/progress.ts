import { SQLiteDatabase } from 'expo-sqlite';
import { ProgressPoint, ExercisePR, Exercise } from '../types';

export async function getExerciseHistory(
  db: SQLiteDatabase,
  traineeId: number,
  exerciseId: number
): Promise<ProgressPoint[]> {
  return db.getAllAsync<ProgressPoint>(
    `SELECT
      sess.date,
      sess.id as session_id,
      MAX(s.weight_kg) as best_weight,
      MAX(s.reps) as best_reps,
      MAX(CASE WHEN s.weight_kg IS NOT NULL AND s.reps IS NOT NULL
        THEN s.weight_kg * (1 + s.reps / 30.0) ELSE NULL END) as estimated_1rm,
      MAX(s.duration_seconds) as best_duration
    FROM sets s
    JOIN session_exercises se ON s.session_exercise_id = se.id
    JOIN sessions sess ON se.session_id = sess.id
    WHERE sess.trainee_id = ? AND se.exercise_id = ?
    GROUP BY sess.id, sess.date
    ORDER BY sess.date ASC`,
    [traineeId, exerciseId]
  );
}

export async function getAllPRs(db: SQLiteDatabase, traineeId: number): Promise<ExercisePR[]> {
  return db.getAllAsync<ExercisePR>(
    `SELECT
      e.id as exercise_id,
      e.name as exercise_name,
      MAX(s.weight_kg) as pr_weight,
      MAX(CASE WHEN s.weight_kg IS NOT NULL AND s.reps IS NOT NULL
        THEN s.weight_kg * (1 + s.reps / 30.0) ELSE NULL END) as pr_1rm,
      MAX(s.reps) as pr_reps,
      MAX(s.duration_seconds) as pr_duration,
      COUNT(DISTINCT sess.id) as session_count
    FROM sets s
    JOIN session_exercises se ON s.session_exercise_id = se.id
    JOIN sessions sess ON se.session_id = sess.id
    JOIN exercises e ON se.exercise_id = e.id
    WHERE sess.trainee_id = ?
    GROUP BY e.id, e.name
    ORDER BY e.name ASC`,
    [traineeId]
  );
}

export async function getLoggedExercises(db: SQLiteDatabase, traineeId: number): Promise<Exercise[]> {
  return db.getAllAsync<Exercise>(
    `SELECT DISTINCT e.id, e.name, e.category, e.created_at
    FROM exercises e
    JOIN session_exercises se ON se.exercise_id = e.id
    JOIN sessions sess ON se.session_id = sess.id
    WHERE sess.trainee_id = ?
    ORDER BY e.name ASC`,
    [traineeId]
  );
}

export async function getTraineeStats(
  db: SQLiteDatabase,
  traineeId: number
): Promise<{ session_count: number; exercise_count: number; first_date: string | null }> {
  const result = await db.getFirstAsync<{ session_count: number; exercise_count: number; first_date: string | null }>(
    `SELECT
      COUNT(DISTINCT sess.id) as session_count,
      COUNT(DISTINCT se.exercise_id) as exercise_count,
      MIN(sess.date) as first_date
    FROM sessions sess
    LEFT JOIN session_exercises se ON se.session_id = sess.id
    WHERE sess.trainee_id = ?`,
    [traineeId]
  );
  return result ?? { session_count: 0, exercise_count: 0, first_date: null };
}
