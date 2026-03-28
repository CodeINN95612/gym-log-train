import { SQLiteDatabase } from 'expo-sqlite';
import { CREATE_TABLES_SQL } from './schema';

export async function migrateDb(db: SQLiteDatabase) {
  await db.execAsync('PRAGMA foreign_keys = ON;');
  const result = await db.getFirstAsync<{ user_version: number }>('PRAGMA user_version');
  const currentVersion = result?.user_version ?? 0;

  if (currentVersion < 1) {
    await db.execAsync(CREATE_TABLES_SQL);
    await db.execAsync('PRAGMA user_version = 1');
  }
}
