# SelfCare

A pink-themed wellness companion for your tasks, focus, mood, and mindful moments.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Play Store](https://img.shields.io/badge/Play%20Store-coming%20soon-ec407a)

SelfCare brings task management, focused study sessions, mood tracking, and self-care routines into one calm, offline-first mobile app. Everything you log stays on your device.

## Features

### Tasks
- Create, edit, and delete tasks with titles, notes, and due dates
- Schedule reminders backed by local notifications
- Mark tasks complete with a single tap

### Study
- Pomodoro timer with configurable focus and break intervals
- Daily streak tracking to keep momentum
- Session history surfaced in the dashboard

### Mood & Journal
- Daily mood check-in on a 5-point scale
- Tag your feelings and add free-form notes
- Journal entries with rich text and search

### Self-care
- Guided breathing exercise with animated pacing
- Curated self-care prompts and ideas

### Notifications
- Local reminders for tasks and check-ins
- Exact-alarm-ready scheduling for reliable delivery

### Offline
- 100% offline-first storage powered by Hive
- No account, no sign-in, no cloud sync required

### Theming
- Polished pink palette with light and dark modes
- Optional premium theme unlock via rewarded ad

## Screenshots

| Home | Tasks | Study |
| --- | --- | --- |
| ![Home](screenshots/home.png) | ![Tasks](screenshots/tasks.png) | ![Study](screenshots/study.png) |

| Mood | Journal | Self-care |
| --- | --- | --- |
| ![Mood](screenshots/mood.png) | ![Journal](screenshots/journal.png) | ![Self-care](screenshots/selfcare.png) |

## Tech stack

- Flutter 3.x
- Dart
- Riverpod for state management
- Hive for local persistence
- flutter_local_notifications
- google_mobile_ads
- intl
- fl_chart
- percent_indicator
- google_fonts

## Getting started

```bash
flutter pub get
flutter run
```

### Release build

```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
```

## Project structure

```
lib/
  Models/        # Data classes and Hive adapters
  Services/      # Ads, notifications, storage, timers
  providers/     # Riverpod providers and controllers
  Screens/       # Top-level UI surfaces
  Widgets/       # Reusable UI components
  utils/         # Theme, constants, helpers
```

## Ads configuration

SelfCare uses Google Mobile Ads (AdMob). In debug builds, Google's official test ad unit IDs are used so you never serve real ads during development. To go live, replace the production constants in `lib/Services/ads_service.dart` with your own AdMob unit IDs (banner, native, interstitial, and rewarded).

Ad placements:
- Banner anchored to the bottom of the Home dashboard
- Native ad inserted into the task list every 5 to 7 items
- Interstitial after completing a task or finishing a study session (with cooldown)
- Optional rewarded ad to unlock the premium theme

## Privacy

See [privacy_policy.md](privacy_policy.md) for details on data handling.

## License

Released under the MIT License. See `LICENSE` for the full text.
