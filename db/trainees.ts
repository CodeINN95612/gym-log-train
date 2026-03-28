import { SQLiteDatabase } from 'expo-sqlite';
import { Trainee } from '../types';

export async function getAllTrainees(db: SQLiteDatabase): Promise<Trainee[]> {
  return db.getAllAsync<Trainee>('SELECT * FROM trainees ORDER BY name ASC');
}

export async function getTrainee(db: SQLiteDatabase, id: number): Promise<Trainee | null> {
  return db.getFirstAsync<Trainee>('SELECT * FROM trainees WHERE id = ?', [id]);
}

export async function addTrainee(db: SQLiteDatabase, name: string, notes: string | null): Promise<number> {
  const result = await db.runAsync(
    'INSERT INTO trainees (name, notes, created_at) VALUES (?, ?, ?)',
    [name, notes, Date.now()]
  );
  return result.lastInsertRowId;
}

export async function updateTrainee(db: SQLiteDatabase, id: number, name: string, notes: string | null): Promise<void> {
  await db.runAsync('UPDATE trainees SET name = ?, notes = ? WHERE id = ?', [name, notes, id]);
}

export async function deleteTrainee(db: SQLiteDatabase, id: number): Promise<void> {
  await db.runAsync('DELETE FROM trainees WHERE id = ?', [id]);
}
