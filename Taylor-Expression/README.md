![Swift Expression Logo](image.png)
# Swift Expression 🎤

An iOS app that reads your facial expression through your camera roll and recommends a Taylor Swift song that matches how you're feeling — powered by a Core ML model trained on facial emotions.

---

## About the Project

Swift Expression was built as a learning project focused on **Core ML** and **Vision** framework integration in SwiftUI. The app detects one of five emotions from a photo and responds with a matching Taylor Swift song, complete with lyrics and (for some emotions) an embedded YouTube video.

---

## How It Works

1. The user opens the app and taps **Start**
2. A photo is selected from the photo library
3. The image is passed to a **Core ML model** (`FacialExpressions.mlmodel`) via the Vision framework
4. The model classifies the face into one of five emotions: `happy`, `sad`, `angry`, `fear`, or `love`
5. A random Taylor Swift song matching that emotion is shown, along with its lyrics

---

## Features

- Facial emotion detection using a custom-trained Core ML model
- 5 emotion categories, each mapped to a curated set of Taylor Swift songs and lyrics
- Embedded YouTube player for some song results
- Custom `Satisfaction` font for the title screen
- Clean card-based result UI with the user's photo displayed

---

## Requirements

- **Xcode** 15 or later
- **iOS** 17 or later
- **Swift** 5.9 or later
- A **physical device** is recommended for photo picker functionality (simulator may have limitations)

---

## Running the Project

1. Clone or download the repository
2. Open the `.xcodeproj` file in Xcode
3. Make sure the following files are included in the project bundle:
   - `FacialExpressions.mlmodel` — the Core ML model
   - `Satisfaction.ttf` — the custom font (must be registered in `Info.plist` under `UIAppFonts`)
   - The `vinho` color asset in the Asset Catalog
4. Select a simulator or device and press **Run (⌘R)**

> The app requires photo library access. Make sure `NSPhotoLibraryUsageDescription` is set in `Info.plist`.

---

## Project Structure

```
SwiftExpression/
├── TaylorExpressionApp.swift   # App entry point
├── ContentView.swift           # Start screen with custom font title
├── LoadingView.swift           # Photo picker + Core ML trigger
├── ResultPage.swift            # Emotion result + song + lyrics + YouTube embed
├── CoreMLViewModel.swift       # Vision + Core ML image classification logic
├── Songs.swift                 # Song lyrics dictionaries by emotion (happy, sad, angry, fear, love)
├── FacialExpressions.mlmodel   # Trained facial expression classifier
├── taylor_lyrics.csv           # Raw lyrics dataset (reference)
└── Satisfaction.ttf            # Custom display font
```

---

## Emotions & Songs

| Emotion | Description |
|---------|-------------|
| 😊 Happy | Upbeat Taylor tracks with YouTube embed |
| 😢 Sad | Melancholic songs matched to sad expressions |
| 😡 Angry | High-energy tracks for anger |
| 😨 Fear | Songs matched to fearful or anxious expressions |
| 🩷 Love | Romantic tracks for loving expressions |

Each emotion maps to a dictionary of songs in `Songs.swift`, and one is picked randomly on every result.

---

## Authors
Camila Ruiz Toniato

Enzo Ferroni

Gustavo Pinotti

Tamires Mendes

Thais Canguçu

Yasmin Mendes
