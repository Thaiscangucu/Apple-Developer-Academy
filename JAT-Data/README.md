# JAT Data

> Available on the App Store: [Download JAT Data](https://apps.apple.com/br/app/jat-data/id6747201031)

JAT Data is an iOS app designed to help self-employed workers and small business owners organize their business — tracking products, managing stock, and monitoring sales, all in one place.

This was our **first app published on the App Store**, built with SwiftUI and Core Data.

**Created by:** Thais Canguçu, Anshu Li & João Vitor Rocha Miranda

---

## Features

- **Product management** — add products with name, stock quantity, purchase price, and sell price
- **Sales tracking** — increment or decrement units sold directly from the product list using a stepper
- **Search** — filter products by name in real time
- **Persistent storage** — all data is saved locally using Core Data and persists between sessions
- **Swipe to delete** — remove products with a swipe gesture

---

## Requirements

- **Xcode** 15 or later
- **iOS** 17 or later
- **Swift** 5.9 or later

---

## Running the Project

1. Clone or download the repository
2. Open the `.xcodeproj` file in Xcode
3. Make sure the Core Data model file `Tracker.xcdatamodeld` is included in the project (it defines the `Product` entity)
4. Select a simulator or device and press **Run (⌘R)**

> No external dependencies or API keys are required — everything runs locally.

---

## Project Structure

```
Tracker/
├── TrackerApp.swift           # App entry point
├── ContentView.swift          # Root view, loads ProductStockView
├── ContentViewModel.swift     # ObservableObject bridging views and Core Data
├── CoreDataController.swift   # Singleton managing the Core Data stack
├── ProductStockView.swift     # Main list with search and add button
├── ProductView.swift          # Individual product card with stepper
└── CreateProductForm.swift    # Sheet form for creating new products
```

---

## Architecture

The app follows a simple **MVVM** pattern:

- `CoreDataController` is a singleton responsible for all persistence operations (create, fetch, delete, sell, undo sell)
- `ContentViewModel` is an `ObservableObject` that the views subscribe to, acting as the bridge between the UI and Core Data
- Views are kept as clean as possible, delegating all logic to the ViewModel

