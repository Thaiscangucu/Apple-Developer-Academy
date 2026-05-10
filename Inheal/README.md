# Inheal

Inheal is an interactive Swift Playgrounds app designed to help young adults and students cope with anxiety. By providing accessible tools like guided breathing, sensory grounding exercises, and habit tracking, Inheal empowers users to manage stress and regain focus during overwhelming moments.

This project was developed for the **Swift Student Challenge**, inspired by my personal experience of anxiety as a young adult. The application provides professional-guided tasks to assist individuals in managing anxiety crises and preventing their occurrence. These tasks include:

* Breathing exercises
* Description cards for thought-distracting 
* Calm song recommendations
* A comprehensive list of healthy habits to mitigate anxiety

**Created by:** Thais Canguçu

---

## About the Project

Anxiety can be a challenging part of starting college or facing new situations. Inheal was built with SwiftUI to offer an immediate, accessible toolkit for anxiety relief. The app is divided into three main coping strategies: a visual breathing guide, a 5-4-3-2-1 sensory grounding technique (Description Cards), and a healthy habit tracker paired with scientific facts about anxiety management.

The app is fully built using **SwiftUI** and leverages native frameworks for fluid animations and state management.

---

## Core Tools

| Feature | Description |
|-------------|---------|
| Breathe | A visual and timed breathing exercise (inhale, hold, exhale) to help stabilize the autonomic nervous system. |
| Description Cards | An interactive 5-4-3-2-1 sensory grounding exercise to interrupt anxiety spirals by focusing on the present environment. |
| Habits & Facts | A checklist for healthy routines (hydration, sleep) paired with randomized educational facts about the body's response to stress. |

---

## Features

- **Guided Breathing Animation** — Uses `Timer.publish` and dynamic scaling to provide a visual cue for deep breathing exercises.
- **Sensory Grounding Carousel** — A paginated `ScrollView` that guides the user through the 5-4-3-2-1 method, focusing on sight, touch, hearing, smell, and taste.
- **Educational Onboarding** — A 3-page animated introduction explaining anxiety and the app's purpose, saved via `@AppStorage` so it only shows on the first launch.
- **Interactive To-Do List** — A habit tracker where users can check off daily goals or swipe to delete them.
- **Randomized Fact Engine** — Displays shuffled scientific facts about anxiety (e.g., Vagus Nerve stimulation, Mammalian Dive Reflex) every time the Habits view is opened.

---

## Requirements

- **Xcode** 15+ or **Swift Playgrounds** 4+
- **iOS / iPadOS** 17.0 or later
- **Swift** 5.9 or later

---

## Running the Project

1. Clone or download the repository.
2. Open the project folder in **Swift Playgrounds** on your iPad/Mac, or open it in **Xcode**.
3. Ensure all source files (`.swift`) and assets (images for the onboarding like "Person", "Hat", "Meditading") are present in the project navigator.
4. Select a simulator or physical device.
5. Press **Run (⌘R)**.

---

## Project Structure

```text
Inheal/
├── ContentView.swift             # Main TabView navigating between Breathe, Cards, and Habits
├── BreatheView.swift             # Breathing exercise with growing/shrinking animations and timers
├── DescriptionCardsView.swift    # 5-4-3-2-1 sensory grounding technique using horizontal ScrollView
├── HabitsView.swift              # Healthy habits checklist and randomized anxiety facts
└── OnBoarding.swift              # First-launch educational carousel about anxiety
