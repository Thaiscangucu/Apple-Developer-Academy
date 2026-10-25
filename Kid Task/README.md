# Kid Task

> Currently in beta testing via **TestFlight**.

Kid Task is an iOS app that helps children build routines with their caregivers. Kids see their daily tasks as colorful cards with big titles, SF Symbols and read-aloud text. Caregivers confirm completed tasks with a password, attach an "after" photo, and set up rewards the child earns over time. Finished tasks are saved in a memory book the family can browse together.

Built entirely with SwiftUI and Core Data.

**Created by:** Camila Parolin, Matheus Motta and Thais Canguçu

---

## Features

- **Onboarding**: first-launch setup for the caregiver's name, the child's name and a caregiver password
- **Task cards**: each task has a title, description, date, illustration, card color and up to 3 SF Symbols, shown in a paged horizontal carousel
- **Read aloud**: tap a task title to hear it spoken in Brazilian Portuguese (`AVSpeechSynthesizer`)
- **Caregiver confirmation**: marking a task as done requires the caregiver password, a performance rating (easy / medium / hard) and an optional "after" photo from the camera or photo library
- **Rewards**: puzzle-piece rewards with a title, symbol, color and target frequency (1, 2, 3, 5 or 10 times)
- **Memories**: a book that opens to show every completed task with its date and "after" photo
- **Guardian**: a mascot screen that cheers the child on by name
- **Connection**: a searchable list of professionals (educational psychologists, occupational therapists, psychotherapists) with expandable contact details
- **Local notifications**: one-time, daily and interval-based reminders
- **Persistent storage**: all data saved locally with Core Data

---

## Requirements

- **Xcode** 26.2 or later
- **iOS** 26.2 or later
- **Swift** 5 (language mode), with `MainActor` as the default actor isolation

---

## Running the Project

1. Clone or download the repository
2. Open `NewKiddyTask.xcodeproj` in Xcode
3. Make sure the Core Data model (`ViewModel/Model.xcdatamodeld`) is included. It defines the `Tarefa`, `Recompensa` and `ScheduledNotification` entities
4. Select a simulator or device and press **Run (⌘R)**

> The camera picker and local notifications need a physical device to test fully. Choosing "Camera" on the simulator will crash, because the simulator has no camera.

---

## Project Structure

```
Kid Task/
├── NewKiddyTask/
│   ├── NewKiddyTaskApp.swift        # App entry point
│   ├── ContentView.swift            # Onboarding gate + TabView (Menu / Memories / Connection)
│   ├── CameraPicker.swift           # UIImagePickerController wrapper for the camera
│   ├── Views/
│   │   ├── WelcomeView.swift        # First-launch form: names + caregiver password
│   │   ├── TaskView.swift           # Caregiver confirmation sheet (rating, photo, password)
│   │   ├── RewardsView.swift        # Rewards grid with puzzle pieces
│   │   ├── OpenableBook.swift       # 3D book-opening animation
│   │   ├── Forms/
│   │   │   ├── NewTaskForm.swift    # Create a task
│   │   │   └── NewRewardForm.swift  # Create a reward
│   │   └── Tab Views/
│   │       ├── HomeView.swift       # Today's tasks carousel + add button
│   │       ├── MemoriasView.swift   # Closed memory book
│   │       ├── PageView.swift       # Open book with completed tasks
│   │       ├── GuardianView.swift   # Mascot encouragement screen
│   │       └── ConexaoView.swift    # Professionals list + search bar
│   ├── Components/                  # Buttons, fields, pickers, task card, puzzle pieces
│   ├── Resources/Fonts/Qilka.otf    # Custom font
│   └── Assets.xcassets              # Images, card colors and app icon
├── ViewModel/
│   ├── CoreDataViewModel.swift      # @Observable ViewModel used by the views
│   ├── Model.xcdatamodeld           # Core Data model
│   └── Model/
│       ├── CoreData/CoreDataModel.swift               # Core Data stack + CRUD
│       └── Notifications/NotificationManagerModel.swift  # Local notification scheduling
├── NewKiddyTaskTests/
└── NewKiddyTaskUITests/
```

---

## Architecture

The app uses **MVVM** with Core Data as the persistence layer:

- `CoreDataModel` is a singleton that owns the `NSPersistentContainer` and handles create, fetch, toggle and delete for each entity
- `CoreDataViewModel` is an `@Observable` class created in `ContentView` and passed down to the views. It holds the `tarefas`, `recompensas` and `scheduledNotifications` arrays that the UI reads
- Views stay mostly free of persistence logic and call the ViewModel to create or update data
- `@AppStorage` keeps lightweight values such as `firstTime`, `kidName`, `parentName` and the caregiver `password`

---

## How Task Completion Works

A new `Tarefa` starts with `done = false`. When the child taps the circle on a task card, the caregiver confirmation sheet opens. After the caregiver enters the correct password, the task is toggled to `done`, the "after" photo is stored as JPEG data in `picAfter`, and the card shows a star. Every task with `done = true` becomes a page in the **Memories** book, showing its title, date and photo.

---

## Roadmap

- [ ] Track reward progress (the counter currently always shows `0/n`)
- [ ] Validate empty fields before saving a reward
- [ ] Save photos taken with the camera to the task, not only photos from the library
- [ ] Handle the keyboard covering the onboarding fields
- [ ] Make the Guardian message react to the child's real progress
