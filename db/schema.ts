export const CREATE_TABLES_SQL = `
PRAGMA journal_mode = WAL;

CREATE TABLE IF NOT EXISTS trainees (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  notes TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS plan_days (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trainee_id INTEGER NOT NULL,
  weekday INTEGER NOT NULL,
  label TEXT,
  FOREIGN KEY (trainee_id) REFERENCES trainees(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS plan_day_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plan_day_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  FOREIGN KEY (plan_day_id) REFERENCES plan_days(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trainee_id INTEGER NOT NULL,
  plan_day_id INTEGER,
  date TEXT NOT NULL,
  notes TEXT,
  started_at INTEGER,
  ended_at INTEGER,
  FOREIGN KEY (trainee_id) REFERENCES trainees(id) ON DELETE CASCADE,
  FOREIGN KEY (plan_day_id) REFERENCES plan_days(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS session_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_exercise_id INTEGER NOT NULL,
  set_number INTEGER NOT NULL,
  reps INTEGER,
  weight_kg REAL,
  duration_seconds INTEGER,
  completed INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (session_exercise_id) REFERENCES session_exercises(id) ON DELETE CASCADE
);
`;
