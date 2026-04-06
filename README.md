# GymTrainLog

A free, local-only Android app for personal trainers to manage trainees, plan weekly workouts, log sessions, and track progress over time. No account, no cloud, no ads.

> **Download the latest APK** from the [Releases](../../releases) page.

---

## Features

- **Trainees** — manage a list of clients, each with their own plans and session history
- **Weekly plans** — set up a 7-day training template per trainee with exercises per day
- **Session logging** — start a session from a plan or from scratch; log sets with weight (kg), reps, and/or duration (seconds)
- **Rest timer** — built-in countdown timer with vibration alert; presets at 60s, 90s, 2m, 3m
- **Progress tracking** — per-exercise charts and personal records (best weight, best reps, estimated 1RM)
- **Exercise library** — 80+ seeded common exercises organised by movement pattern and muscle focus; add your own
- **Fully offline** — all data stored locally on device via SQLite, nothing leaves your phone

---

## Screenshots

> Coming soon.

---

## Installing the APK

1. Go to [Releases](../../releases) and download `app-arm64-v8a-release.apk` (most modern phones)
2. On your Android device: **Settings → Install unknown apps** → allow your browser or file manager
3. Open the downloaded file and tap **Install**

> If unsure which APK to use: `arm64-v8a` covers ~95% of devices made after 2016. Try `armeabi-v7a` if it doesn't install.

---

## Building from Source

**Prerequisites:** Flutter 3.x stable, Java 17, Android SDK

```bash
git clone https://github.com/CodeINN95612/gym-log-train.git
cd gym-log-train
flutter pub get
flutter run                          # debug on connected device
flutter build apk --release --split-per-abi   # release APKs
```

### Running tests

```bash
flutter test
```

Tests run entirely on the host machine — no emulator or device needed. The database layer uses an in-memory SQLite via `sqflite_common_ffi`.

---

## Tech stack

| Layer | Library |
|---|---|
| State management | `provider` (ChangeNotifier) |
| Database | `sqflite` with WAL mode + foreign keys |
| Charts | `fl_chart` |
| Rest timer vibration | `vibration` |
| Date formatting | `intl` |
| GitHub link | `url_launcher` |
| Tests | `sqflite_common_ffi`, `fake_async` |

---

## CI/CD

| Workflow | Trigger |
|---|---|
| Tests | Every push and pull request |
| Release APK | Push a tag matching `v*.*.*` |

To cut a release:
```bash
git tag v1.2.0
git push origin v1.2.0
```

GitHub Actions builds the APKs and attaches them to a GitHub Release automatically.

---

## Project structure

```
lib/
├── core/
│   ├── constants/       # exercise categories, muscle focus lists
│   ├── database/        # SQLite helper + versioned migrations
│   ├── models/          # plain Dart models (no codegen)
│   ├── repositories/    # typed query methods, injectable Database
│   └── utils/           # date helpers, 1RM calculator
├── features/
│   ├── about/           # About screen
│   ├── exercises/       # exercise library + add exercise sheet
│   ├── plan/            # weekly plan editor
│   ├── progress/        # charts and PR cards
│   ├── sessions/        # session logging, rest timer
│   └── trainees/        # trainee list and overview
└── shared/widgets/      # reusable widgets (timer, exercise picker, set row…)
```

---

## Privacy

This app collects no data. Everything stays on your device. See the full [Privacy Policy](https://codeirnn95612.github.io/gym-log-train/privacy-policy).

---

## License

MIT
