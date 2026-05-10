# Terminal Typing 🎵⌨️

A terminal-based rhythm typing game built in Swift, inspired by Guitar Hero. Letters fall down the screen in sync with music — press the right key at the right moment to score points!

**Created by:** Thais, João e Miqueias
**GitHub:** https://github.com/Thaiscangucu/Terminal-Typing

---

## How It Works

Letters (`D`, `F`, `J`, `K`) fall down a grid on your terminal. Hit the correct key precisely when a letter reaches the bottom line to score. Miss a key — or press the wrong one — and it's **Game Over**.

The game ends naturally when the song finishes, showing the **End Game** screen instead.

---

## Features

- ASCII art title screen, Game Over, and End Game screens
- 3 song genres: **Rock**, **Pop**, and **Hip Hop**
- 3 difficulty levels that control the speed of falling letters
- Real-time key input (no Enter required)
- Live score display during gameplay
- Music playback via `AVFoundation`

---

## Requirements

- **macOS** (required — `AVFoundation` and `Darwin` are Apple-only frameworks)
- **Swift** 5.0 or later
- Xcode Command Line Tools installed

To check if Swift is available:
```bash
swift --version
```

To install Xcode Command Line Tools if needed:
```bash
xcode-select --install
```

---

## Setup: Music Files

> ⚠️ **This step is required before compiling.**

The game plays local `.mp3` files. You need to update the file paths in `Game.swift` to match where the audio files are stored on **your** machine.

Open `Game.swift` and find all calls to `playMusic(...)`. Replace each hardcoded path with the actual path to the corresponding file on your computer. Example:

```swift
// Before
playMusic("/Users/thaiscangucu/Desktop/Academy/.../Sweet Child O Mine - short version.mp3")

// After
playMusic("/Users/yourname/Downloads/Sweet Child O Mine - short version.mp3")
```

The audio files needed are:

| File | Used for |
|------|----------|
| `Sweet Child O Mine - short version.mp3` | Rock — Easy / Medium |
| `Sweet Child O Mine - 2x speed.mp3` | Rock — Hard |
| `Shake It Off - short version.mp3` | Pop — Easy / Medium |
| `Shake It Off - 2x speed.mp3` | Pop — Hard |
| `Not Like Us - short version.mp3` | Hip Hop — Easy / Medium |
| `Not Like Us - 2x speed.mp3` | Hip Hop — Hard |

---

## Compilation

Place all Swift files in the same folder, then run:

```bash
swiftc main.swift Board.swift Game.swift Menu.swift -o TerminalTyping
```

---

## Running

```bash
./TerminalTyping
```

---

## How to Play

1. At the main menu, type `start` and press Enter
2. Choose a song genre (1 = Rock, 2 = Pop, 3 = Hip Hop)
3. Choose a difficulty (1 = Easy, 2 = Medium, 3 = Hard)
4. Type `start` again when prompted — a 3-second countdown begins
5. When letters fall, press the matching key **before they cross the bottom line**:

| Key | Column |
|-----|--------|
| `D` | Left |
| `F` | Center-left |
| `J` | Center-right |
| `K` | Right |

6. The game ends when the song finishes (**End Game**) or when you press the wrong key (**Game Over**)
7. Type `back` to return to the menu

---

## Project Structure

```
.
├── main.swift    # Entry point, global variables
├── Board.swift   # Grid logic, rendering, letter movement
├── Game.swift    # Game loop, input handling, music playback
└── Menu.swift    # Menus, difficulty selection, song selection
```

---

## Difficulty Levels

| Level | Speed |
|-------|-------|
| Easy | 0.75 FPS — slow fall |
| Medium | 1.0 FPS — moderate fall |
| Hard | 2.0 FPS — fast fall + 2x speed music |
