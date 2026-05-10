<p align="center">
  <img src="image.png" alt="FisioterApp Banner" width="800"/>
</p>

# Articula

> Aiding the Physiotherapy Recovery Process

FisioterApp is an iOS application designed to assist patients with their physiotherapy routines. By utilizing the device's built-in motion sensors, the app tracks specific physical movements to ensure exercises are performed correctly and counts repetitions automatically. It also features a custom scheduling system to remind users of their daily exercise sessions. 

This application marks our first venture into building interfaces purely programmatically using **UIKit**.

**Created by:** Camila Parolin, Matheus Motta, Yasmin Mendes and Thais Canguçu

---

## About the Project

Consistency is key in physiotherapy. FisioterApp was created to provide patients with an accessible tool to track their progress, maintain focus, and remember their exercises. 

Instead of relying on Storyboards, the entire interface was constructed using ViewCode (programmatic Auto Layout), allowing for highly customized and reusable UI components, such as gradient buttons, custom bottom sheets, and personalized date pickers.

---

## Core Features

| Feature | Description |
|-------------|---------|
| Motion Tracking | Uses the device accelerometer to track physical movements along the Y-axis and count successful exercise repetitions. |
| Custom Notifications | A dedicated scheduling sheet allowing users to pick specific days and times for workout reminders. |
| Progress Reports | Integrates with CoreData to save exercise duration, completion status, and pain rates for future review. |
| Visual & Haptic Feedback | Triggers haptic responses and screen color changes to notify the user when a movement is successfully registered. |

---

## Technical Highlights

- **100% Programmatic UI (ViewCode)** — Built entirely without Storyboards, using `NSLayoutConstraint` for responsive layouts.
- **CoreMotion Integration** — Implements `CMMotionManager` to read real-time accelerometer updates at 0.02-second intervals.
- **Local Notifications** — Uses `UNUserNotificationCenter` to request permissions and schedule recurring weekly alarms.
- **Custom UI Components** — Includes highly reusable views like `FrequencyView`, `TimePickerView`, and `ButtonView` with dynamic `CAGradientLayer` styling.

---

## Requirements

- **Xcode** 15 or later
- **iOS** 16.0 or later
- **Swift** 5.0 or later
- A **physical device** is required to test the accelerometer (`CoreMotion`) and haptic feedback features.

---

## Running the Project

1. Clone or download the repository.
2. Open the project file in Xcode.
3. Ensure your signing capabilities are configured if you are deploying to a physical device.
4. Select your physical iPhone from the run destinations (the simulator cannot test the motion tracking).
5. Press **Run (⌘R)**.

---

## Project Structure

```text
FisioterApp/
├── ViewControllers/
│   ├── HomeViewController.swift              # Main menu and navigation
│   ├── ExerciseViewController.swift          # CoreMotion logic, timers, and repetition counting
│   └── NotificationSheetViewController.swift # Bottom sheet for scheduling alerts
├── Views/
│   ├── ButtonView.swift                      # Reusable gradient button
│   ├── TimePickerView.swift                  # Custom UIDatePicker wrapper
│   ├── FrequencyView.swift                   # Day-of-the-week selection logic
│   ├── ConfirmView.swift                     # Action buttons for the notification sheet
│   └── NotificationToggleView.swift          # Custom switch with gradient background
└── Models/
    └── CoreDataViewModel.swift               # Database operations for physiotherapy reports
