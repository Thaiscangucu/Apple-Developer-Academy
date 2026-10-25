# Articula

Articula is an iOS app that turns physical therapy exercises into a guided, motion-tracked experience. The patient holds the iPhone in the injured hand, and the accelerometer moves a ball on screen as the wrist flexes. Each full movement counts as a repetition, with haptic and color feedback. At the end, the patient logs how the session felt, and the app builds a performance report that can be exported as a PDF and shared with the physical therapist.

Built entirely with UIKit (programmatic layout, no storyboards), Core Motion and Core Data.

**Created by:** Camila Parolin, Matheus Motta, Pedro Henrique L. Moreiras, Thais Canguçu and Yasmin Mendes

---

## Features

- **Exercise library**: home screen with exercise cards for wrist (*Punho*), shoulder (*Ombro*) and ankle (*Tornozelo*)
- **Motion-tracked repetitions**: the accelerometer (`CMMotionManager`, sampled every 0.02 s) moves a ball up and down. Reaching the top and then the bottom counts one repetition
- **Real-time feedback**: a success haptic (`UINotificationFeedbackGenerator`) and a green screen flash for every correct repetition, plus a live "x of 5 repetitions" counter
- **Instructions pop-up**: step-by-step guidance on how to hold the phone before the exercise starts
- **Session timer**: measures how long the patient takes to finish the set
- **Post-exercise feedback**: the patient rates difficulty (easy / medium / hard), autonomy (needed help / didn't need help) and pain level (5-step scale)
- **Performance report**: duration, autonomy, difficulty, pain level and completion for the period, exportable as a **PDF** through the share sheet
- **Exercise reminders**: weekly local notifications with a custom time and a choice of weekdays
- **Persistent storage**: all sessions and reports saved locally with Core Data

---

## Requirements

- **Xcode** 26.2 or later
- **iOS** 26.2 or later
- **Swift** 5
- A **physical iPhone**: the exercise depends on the accelerometer

---

## Running the Project

1. Clone or download the repository
2. Open `FisioterApp.xcodeproj` in Xcode
3. Make sure the Core Data model (`FisioterApp/CoreData/Model.xcdatamodeld`) is included. It defines the `Session` and `Report` entities
4. Connect an iPhone, select it as the run destination and press **Run (⌘R)**

> The simulator has no accelerometer, so the ball will not move and repetitions will not be counted. Local notifications also need a physical device to test fully.

---

## Project Structure

```
Articula/
├── FisioterApp/
│   ├── App/
│   │   ├── AppDelegate.swift                     # App entry point
│   │   └── SceneDelegate.swift                   # Window setup, UINavigationController root
│   ├── Controller/
│   │   ├── HomeViewController.swift              # Exercise cards + notifications and report buttons
│   │   ├── ExerciseViewController.swift          # Accelerometer tracking, rep counting, haptics
│   │   └── Notificationsheetviewcontroller.swift # Reminder time, weekdays and scheduling
│   ├── Model/
│   │   ├── ExerciseTimer.swift                   # Minutes/seconds session timer
│   │   └── ReportModel.swift                     # Report data structure
│   ├── CoreData/
│   │   ├── CoreDataController.swift              # Core Data stack + CRUD
│   │   ├── CoreDataViewModel.swift               # @Observable ViewModel used by the controllers
│   │   └── Model.xcdatamodeld                    # Core Data model
│   ├── View/
│   │   ├── Exercicio/                            # Exercise screen, ball, card button, instructions pop-up, rep labels
│   │   ├── Report/                               # Feedback form, pain buttons, performance report + PDF export
│   │   └── ...                                   # Notification sheet components (toggle, time picker, frequency, confirm)
│   ├── Extensions/                               # UIView, UIViewController, UIImage, Array and picker helpers
│   ├── Assets.xcassets                           # Images, colors and app icon
│   └── Info.plist
└── FisioterApp.xcodeproj
```

---

## Architecture

The app follows **MVC** with a thin ViewModel over Core Data:

- **Controllers** (`HomeViewController`, `ExerciseViewController`, `NotificationSheetViewController`) own the screens, handle navigation and run the device logic (Core Motion, timers, notifications)
- **Views** are custom `UIView` / `UIButton` subclasses built in code with Auto Layout
- `CoreDataController` is a singleton that owns the `NSPersistentContainer` and handles create, fetch, update and delete for `Session` and `Report`
- `CoreDataViewModel` is an `@Observable` class that exposes `sessions` and `reports` to the controllers

---

## How Repetition Tracking Works

While the exercise screen is open, the accelerometer sends a reading every 0.02 s. The Y-axis acceleration moves the ball's vertical position, limited to a fixed range. When the ball passes the top threshold, a `1` is recorded. When it passes the bottom threshold, a `2` is recorded. As soon as the sequence `[1, 2]` appears, the movement is cleared and one repetition is counted, with a haptic and a green flash. After **5 repetitions**, the timer stops, the accelerometer is turned off, a `Report` is saved with the session duration, and the feedback form opens so the patient can add difficulty, autonomy and pain level.

---

## Roadmap

- [ ] Add the report button and the shoulder and ankle exercise cards to the home screen (they are created but not yet added to the view)
- [ ] Save the pain level the patient picks (it is currently fixed at `3`) and persist feedback updates with `saveContext()`
- [ ] Update only the current session's report instead of all reports
- [ ] Add the Montserrat font files listed in `Info.plist` to the project
- [ ] Use the `Session` entity to track history and progress over time
