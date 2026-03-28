import { SQLiteDatabase } from 'expo-sqlite';
import { Exercise } from '../types';

export async function getAllExercises(db: SQLiteDatabase, search = '', category: string | null = null): Promise<Exercise[]> {
  if (category) {
    return db.getAllAsync<Exercise>(
      'SELECT * FROM exercises WHERE category = ? AND name LIKE ? ORDER BY name ASC',
      [category, `%${search}%`]
    );
  }
  return db.getAllAsync<Exercise>(
    'SELECT * FROM exercises WHERE name LIKE ? ORDER BY name ASC',
    [`%${search}%`]
  );
}

export async function addExercise(db: SQLiteDatabase, name: string, category: string | null): Promise<number> {
  const result = await db.runAsync(
    'INSERT INTO exercises (name, category, created_at) VALUES (?, ?, ?)',
    [name, category, Date.now()]
  );
  return result.lastInsertRowId;
}

export async function deleteExercise(db: SQLiteDatabase, id: number): Promise<void> {
  await db.runAsync('DELETE FROM exercises WHERE id = ?', [id]);
}
