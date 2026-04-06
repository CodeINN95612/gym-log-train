# GymLog — Flutter Android App

## Purpose

Build a Flutter Android app called **GymTrainLog** for personal trainers to manage their trainees' workout sessions. There is no authentication — the app is single-user, local-only. All data is stored on-device using SQLite.

---

## Core Concepts

- A trainer manages a list of **trainees** (clients).
- Each trainee has a **weekly plan** — a template that specifies which exercises to do on which days of the week.
- The trainer runs **sessions** with a trainee, optionally using that day's plan as a starting point.
- During a session, exercises are logged with **sets**, where each set tracks reps, weight (kg), and/or duration (seconds) — all optional.
- After sessions accumulate, the app shows **progress charts** and **personal records (PRs)** per exercise per trainee.

---

## Database Schema

Use SQLite with WAL mode and foreign keys enabled. Use the following schema exactly:

```sql
CREATE TABLE trainees (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  notes TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE plan_days (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trainee_id INTEGER NOT NULL,
  weekday INTEGER NOT NULL,  -- 0=Monday, 1=Tuesday, ..., 6=Sunday
  label TEXT,
  FOREIGN KEY (trainee_id) REFERENCES trainees(id) ON DELETE CASCADE
);

CREATE TABLE plan_day_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plan_day_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  FOREIGN KEY (plan_day_id) REFERENCES plan_days(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trainee_id INTEGER NOT NULL,
  plan_day_id INTEGER,
  date TEXT NOT NULL,  -- YYYY-MM-DD
  notes TEXT,
  started_at INTEGER,  -- unix ms
  ended_at INTEGER,    -- unix ms, null while in progress
  FOREIGN KEY (trainee_id) REFERENCES trainees(id) ON DELETE CASCADE,
  FOREIGN KEY (plan_day_id) REFERENCES plan_days(id) ON DELETE SET NULL
);

CREATE TABLE session_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE TABLE sets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_exercise_id INTEGER NOT NULL,
  set_number INTEGER NOT NULL,
  reps INTEGER,           -- nullable
  weight_kg REAL,         -- nullable
  duration_seconds INTEGER, -- nullable
  completed INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (session_exercise_id) REFERENCES session_exercises(id) ON DELETE CASCADE
);
```

---

## Screens and Features

### Bottom Navigation

Two top-level screens:

1. **Trainees** — list of all trainees
2. **Exercises** — the global exercise library

---

### Trainees

**Trainee List Screen**

- Shows all trainees as a list.
- Button to add a new trainee.
- Tapping a trainee opens their overview.

**Add Trainee Screen**

- Fields: name (required), notes (optional, multiline).
- Saves to DB and returns.

**Trainee Overview Screen**

- Shows trainee name and notes.
- Delete button (with confirmation) that cascades to all sessions and plans.
- "Start Session" button → navigates to New Session screen.
- "Progress" button → navigates to Progress screen.
- Weekly plan summary: shows all 7 days (Mon–Sun). Days with a plan entry are shown with their label or exercise count; days without are shown as "Rest".
- "Edit" link on the plan summary → navigates to Plan screen.
- Shows the 5 most recent sessions. "See All" link → navigates to Session History screen.

**Plan Screen** (per trainee)

- Shows all 7 weekdays as rows.
- Tapping an inactive day enables it (creates a plan_day record) and expands it.
- Tapping an active day toggles expand/collapse.
- Expanded day shows its exercises with a remove button per exercise.
- Expanded day has buttons to "Add Exercise" (opens exercise picker) and "Remove Day" (with confirmation, deletes the plan_day).
- A hint text at the top explains the interaction.

**Session History Screen** (per trainee)

- Full list of all sessions, newest first.
- Each session shows: date, number of exercises, in-progress or completed status.
- Tapping opens the session detail.

**New Session Screen** (per trainee)

- Shows today's weekday name.
- If today's weekday has a plan, shows a card with the plan's label/exercise count and a button "Use Today's Plan" — starts a session pre-populated with the plan's exercises (copies plan_day_exercises into session_exercises).
- Always shows an "Ad-hoc Session" card with a "Start Blank Session" button.
- On start: creates a session record with `started_at = now`, then navigates to the session detail screen (replacing the navigation stack entry so back doesn't return here).

**Session Detail Screen** (per trainee/session)

- Header shows date, exercise count, and a status badge (In Progress or Completed).
- Active session (no `ended_at`) shows:
  - A rest timer widget (see below).
  - Each exercise as a block with its sets.
  - "Add Exercise" button (opens exercise picker in session mode).
  - "End Session" button (with confirmation) that sets `ended_at = now`.
- Completed session (has `ended_at`) is read-only — no add/remove/edit controls.

**Rest Timer** (shown during active sessions)

- Countdown timer. Default 90 seconds.
- When a new set is added, the timer starts automatically.
- Shows remaining seconds and a progress indicator.
- "Skip" button dismisses the timer.
- "+30s" button adds 30 seconds to the current countdown.
- Preset duration chips: e.g. 60s, 90s, 120s, 180s — selecting one restarts the timer with that duration and also changes the default for subsequent sets.
- When the timer reaches 0, vibrate the device (two short pulses).

**Exercise Log Block** (inside session detail, per exercise)

- Shows exercise name and category.
- Remove exercise button (with confirmation, deletes exercise and all its sets).
- Shows existing sets as rows: set number, reps field, weight field, duration field (only show fields if the exercise has at least one set with that metric, or show all by default for new sets), delete button per set.
- "Add Set" button appends a new set (with null values) and starts the rest timer.
- Set fields (reps, weight_kg, duration_seconds) are inline editable numeric inputs. Changes are saved immediately (on change/blur).

---

### Exercises (Library)

**Exercise Library Screen**

- Search bar at the top (filters by name).
- Category filter chips below the search bar (filters by category). Categories: Chest, Back, Shoulders, Arms, Legs, Core, Cardio, Full Body, Other.
- List of exercises showing name and category badge.
- "Add" button opens the Add Exercise modal.

**Add Exercise Screen/Modal**

- Fields: name (required), category (optional, single-select from the fixed category list).
- Duplicate name shows an error (UNIQUE constraint).

---

### Progress Screen (per trainee)

**Stats strip at top:**

- Total sessions count.
- Total distinct exercises used.
- Date of first session.

**Personal Records section:**

- Horizontal scrollable list of PR cards, one per exercise the trainee has ever done.
- Each PR card shows: exercise name, best weight, best estimated 1RM, best reps, best duration (show only the fields that have data).

**Exercise Progress section:**

- Horizontal scrollable list of exercise selector chips (all exercises the trainee has logged).
- Selecting an exercise shows a line chart of that exercise's progress over time.
- Metric toggle buttons (only show metrics with actual data): Weight, Reps, Est. 1RM, Duration.
- The chart plots one data point per session where that exercise was logged, using the best value for the selected metric in that session.

**Progress chart queries** (compute per session, per exercise, per trainee):

- `best_weight` = MAX(weight_kg) across all sets of that exercise in that session
- `best_reps` = MAX(reps) across all sets
- `best_duration` = MAX(duration_seconds) across all sets
- `estimated_1rm` = MAX(weight_kg \* (1 + reps / 30.0)) where both weight and reps are non-null

---

## Business Logic Rules

1. Deleting a trainee cascades to their sessions, plan_days, and all child records.
2. Deleting a plan_day cascades to plan_day_exercises; sessions that referenced that plan_day have their plan_day_id set to NULL.
3. When starting a session with a plan, copy all plan_day_exercises into session_exercises preserving order_index.
4. Sessions are ordered by date DESC, started_at DESC.
5. Exercise names must be unique (enforce at DB level, show friendly error on duplicate).
6. Weekdays: 0=Monday through 6=Sunday.
7. A session without `ended_at` is "in progress". A session with `ended_at` is read-only.
8. Sets: reps, weight_kg, and duration_seconds are all independently optional per set. A single session exercise can have some sets with weight+reps and others with only duration.
9. The rest timer is UI state only — not persisted to the database.

---

## UI / UX

Use modern Material 3 design. Prioritize a clean, efficient workflow for a trainer who is actively coaching — fast to log a set, easy to navigate between trainees and sessions. The app should feel responsive and polished.

---

## Technical Requirements

- Flutter, targeting Android (minSdkVersion 21+).
- SQLite for local persistence.
- No backend, no authentication, no network requests.
- Apply database migrations using a version-based approach (PRAGMA user_version).
- Handle all async DB operations gracefully.
- The app name is **GymTrainLog**.
- If components or libraries are needed you can check the internet to validate versions and what is good to install.

### Unit test

- Generate unit tests for domain functionality

### Workflows

- Generate a github workflow to run the unit tests
- Generate a github workflow to publish an apk realease so I can install on my android
