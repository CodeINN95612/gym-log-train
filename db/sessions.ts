import { SQLiteDatabase } from 'expo-sqlite';
import { Session } from '../types';

export async function getSessions(db: SQLiteDatabase, traineeId: number, limit?: number): Promise<Session[]> {
  if (limit) {
    return db.getAllAsync<Session>(
      'SELECT * FROM sessions WHERE trainee_id = ? ORDER BY date DESC, started_at DESC LIMIT ?',
      [traineeId, limit]
    );
  }
  return db.getAllAsync<Session>(
    'SELECT * FROM sessions WHERE trainee_id = ? ORDER BY date DESC, started_at DESC',
    [traineeId]
  );
}

export async function getSession(db: SQLiteDatabase, sessionId: number): Promise<Session | null> {
  return db.getFirstAsync<Session>('SELECT * FROM sessions WHERE id = ?', [sessionId]);
}

export async function createSession(
  db: SQLiteDatabase,
  traineeId: number,
  date: string,
  planDayId: number | null
): Promise<number> {
  const result = await db.runAsync(
    'INSERT INTO sessions (trainee_id, plan_day_id, date, started_at) VALUES (?, ?, ?, ?)',
    [traineeId, planDayId, date, Date.now()]
  );
  return result.lastInsertRowId;
}

export async function endSession(db: SQLiteDatabase, sessionId: number): Promise<void> {
  await db.runAsync('UPDATE sessions SET ended_at = ? WHERE id = ?', [Date.now(), sessionId]);
}

export async function deleteSession(db: SQLiteDatabase, sessionId: number): Promise<void> {
  await db.runAsync('DELETE FROM sessions WHERE id = ?', [sessionId]);
}
