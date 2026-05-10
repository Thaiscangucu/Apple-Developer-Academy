# Batuque

> Explorando a Computação Espacial: [Veja o Vídeo de Demonstração](#)

Batuque is a visionOS application designed to explore the spatial computing capabilities of the **Apple Vision Pro**. By utilizing hand-tracking and 3D space, Batuque allows users to interact with immersive percussion instruments directly in their physical environment. 

This project was created with the main goal of experimenting with visionOS, 3D rendering, and spatial audio interactions.

**Created by:** Tessaro (e sua equipe, se aplicável)

---

## About the Project

Batuque presents interactive 3D models built with **RealityKit** where users can use natural hand gestures to trigger spatial sounds. Each instrument interaction is designed to feel tactile and immediate, taking advantage of the immersive nature of the Apple Vision Pro.

The app uses `RealityKitContent` to manage 3D assets and materials, ensuring high-fidelity visuals seamlessly blended into the user's real-world surroundings.

---

## Spatial Experiences

| Instrument | Interaction |
|-------------|---------|
| Pandeiro | Tap with fingers, shake for continuous sound |
| Atabaque | Strike with open palms for deep bass |
| Coming Soon | More spatial instruments planned |

*Note: Adjust the table above according to the actual 3D objects you implemented in your RealityKit scene.*

---

## Features

- **Spatial Interactions** — Use native visionOS hand gestures (pinch, tap) to interact with 3D instruments.
- **RealityKit Integration** — High-quality 3D models and physics rendered seamlessly using RealityKit.
- **Immersive Audio** — Sounds are anchored to the 3D objects, changing volume and direction as you walk around them.
- **Shared Space / Full Immersive** — Opens in a bounded volume or fully immersive space depending on the user's preference.
- **Swift & Concurrency** — Built using modern Swift approaches and MainActor isolation.

---

## Requirements

- **Xcode** 15 or later (Project configured for latest Apple tools)
- **visionOS** SDK (`xros`)
- **Swift** 5.0 or later
- An **Apple Vision Pro** physical device or the **visionOS Simulator** (`xrsimulator`)

---

## Running the Project

1. Clone or download the repository.
2. Open the `Batuque.xcodeproj` file in Xcode.
3. Make sure the following are included and loading correctly in the project:
   - The `RealityKitContent` Swift Package (contains your 3D scenes, materials, and spatial assets).
   - Audio files for each instrument.
4. Select the **Apple Vision Pro Simulator** (or your physical device) in the run destination menu.
5. Press **Run (⌘R)**.

---

## Project Structure

```text
Batuque/
├── BatuqueApp.swift                  # App entry point; defines the WindowGroup or ImmersiveSpace
├── ContentView.swift                 # Main UI for selecting instruments or starting the experience
├── RealityKitContent/                # Swift Package containing 3D assets and Reality Composer Pro scenes
│   ├── Package.swift                 # Package definition
│   └── Sources/RealityKitContent/    # RealityKit scenes and logic
├── ViewModels/                       # Logic for handling gestures and audio playback
└── Models/                           # Data structures for the instruments
