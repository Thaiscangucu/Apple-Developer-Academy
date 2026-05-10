# Habits — Improve

> Available on the App Store: [Download Habits — Improve](https://lnkd.in/eDsYAZxu)

Habits — Improve is an iOS app designed to encourage young people to build healthy habits. Add personalized habits with custom goals and daily reminders, and visualize your monthly progress through a pixel calendar — one colored square for every day you complete your habit.

This is my **first solo app published on the App Store**, built entirely with SwiftUI and Core Data.

**Created by:** Thais Canguçu

---

## Features

- **Habit creation** — add habits with a custom title, description, daily goal (quantity + unit), and optional daily reminders
- **Pixel calendar** — each completed day is painted green on a monthly grid; incomplete days stay gray
- **Streak tracking** — a running streak counter that resets if you miss a day
- **Progress page** — see a pixel calendar for every habit at a glance
- **Habit detail page** — view today's count, total, and average per completed day
- **Onboarding** — a swipeable intro flow shown on first launch
- **Edit & delete** — update any habit's settings or remove it with a swipe
- **Daily notifications** — scheduled reminders via local notifications
- **Localization** — app strings managed via `Localizable.xcstrings`
- **Persistent storage** — all data saved locally with Core Data

---

## Requirements

- **Xcode** 16 or later
- **iOS** 18 or later
- **Swift** 5.9 or later

---

## Running the Project

1. Clone or download the repository
2. Open the `.xcodeproj` file in Xcode
3. Make sure the Core Data model file (`HabitosImprove.xcdatamodeld`) is included — it defines the `Habit`, `Day`, and `Streak` entities
4. Select a simulator or device and press **Run (⌘R)**

> Local notifications require a physical device to test fully. The simulator may not deliver notifications as expected.

---

## Project Structure

```
HabitosImprove/
├── HabitosImproveApp.swift   # App entry point
├── ContentView.swift         # Onboarding gate + TabView (Home / Progress)
├── OnboardingView.swift      # First-launch swipeable intro (4 steps)
├── HomePage.swift            # Main screen: habit cards, streak button, add button
├── HabitPage.swift           # Individual habit detail: count, stats, pixel calendar
├── HabitFormView.swift       # Create / edit habit form with reminders
├── ProgressPage.swift        # All habits overview with monthly pixel calendars
├── StreakPage.swift          # Streak count display
├── AllHabits.swift           # Full habit list with swipe-to-delete
└── Localizable.xcstrings     # Localization strings
```

---

## Architecture

The app uses **MVVM** with Core Data as the persistence layer:

- `CoreDataViewModel` is a shared `ObservableObject` that handles all CRUD operations for `Habit`, `Day`, and `Streak` entities
- Views observe the ViewModel via `@StateObject` or `@ObservedObject` and stay free of business logic
- `UserDefaults` + `@AppStorage` handle lightweight flags like onboarding status, streak creation, and daily reset timestamps

---

## How the Pixel Calendar Works

When a habit is created, a `Day` record is generated for each day of the current month. Every day starts as `"cinza"` (gray). When the user logs progress and the habit count is above zero, the day is updated to `"verde"` (green). The pixel grid renders each day's color as a small colored square, giving a GitHub-style contribution calendar for each habit.


