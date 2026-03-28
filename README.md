# GymLogTrain

A mobile app for personal trainers to manage trainees, create weekly training plans, and log workout sessions. Built with Expo (React Native) for Android.

## Features

- **Trainee management** — add and manage multiple trainees
- **Weekly plan templates** — create per-day training plans for each trainee
- **Session logging** — log exercises with sets, reps, weight, and duration
- **Exercise library** — searchable, filterable list of exercises; add custom exercises
- **Rest timer** — between-set countdown with presets, +30s, and vibration alert
- **Progress tracking** — per-exercise history charts (weight, reps, est. 1RM, duration)
- **Personal records** — automatic PR detection across all logged sessions

## Tech Stack

- **Expo SDK 52** with Expo Router v4 (file-based navigation)
- **expo-sqlite** — local SQLite database, no backend required
- **NativeWind v4** — Tailwind CSS utility classes for React Native
- **TypeScript**
- **react-native-gifted-charts** — line charts for progress graphs

## Getting Started

### Prerequisites

- Node.js 18+
- Expo Go app on your Android device (for development)

### Run in development

```bash
npm install
npx expo start
```

Scan the QR code with the Expo Go app.

> **Note:** This app requires Expo SDK 52. If you have an older version of Expo Go, download the latest from the Play Store.

## Building an APK

To install directly on Android without the Play Store:

1. Install EAS CLI and log in:
   ```bash
   npm install -g eas-cli
   eas login
   ```

2. Configure the build:
   ```bash
   eas build:configure
   ```

3. Build the APK:
   ```bash
   eas build --platform android --profile preview
   ```

4. Download the `.apk` from the EAS dashboard and install it on your device.

The `eas.json` preview profile is already configured to produce an APK (not an AAB bundle).

## Project Structure

```
app/
  (tabs)/          # Bottom tab screens (Trainees, Library)
  trainees/[id]/   # Trainee detail, plan, history, session, progress
  modals/          # Exercise picker, add exercise, add trainee
components/
  library/         # CategoryFilter, ExerciseListItem
  progress/        # PRCard, ProgressChart
  sessions/        # ExerciseLogBlock, RestTimer, SessionCard
  trainees/        # TraineeCard
  ui/              # Button, Input, EmptyState
db/
  schema.ts        # Table definitions and migrations
  exercises.ts
  sessions.ts
  exercise-logs.ts
  progress.ts
hooks/             # useLibrary, useSession, useProgress, etc.
types/             # Shared TypeScript interfaces
```

## Data Model

All data is stored locally in SQLite. Key tables:

- `trainees` — name + notes
- `exercises` — name + category (from a fixed list)
- `plan_days` + `plan_day_exercises` — weekly templates per trainee
- `sessions` — one session per visit (linked to a plan day or ad-hoc)
- `session_exercises` + `sets` — logged exercises with reps/weight/duration per set
